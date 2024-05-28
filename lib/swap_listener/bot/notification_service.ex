defmodule SwapListener.Bot.NotificationService do
  @moduledoc false
  import SwapListener.I18n.Gettext

  alias SwapListener.ChatSubscription.ChatSubscriptionManager

  require Decimal
  require Logger

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  def handle_notification(notification) do
    Logger.debug("Handling notification: #{inspect(notification)}")

    # skip if updated_at is more than a minute ago

    with {:ok, details} <- process_notification(notification),
         true <- was_created_recently?(details.updated_at),
         :ok <- broadcast(details) do
      Logger.debug("Notification processed and broadcast successfully")
    else
      error ->
        Logger.error("Failed to process notification: #{inspect(error)}")
    end
  end

  defp was_created_recently?(created_at) do
    case DateTime.from_iso8601("#{created_at}Z") do
      {:ok, dt, _} ->
        now = DateTime.utc_now()
        diff = DateTime.diff(now, dt, :second)
        diff < 60
    end
  end

  defp send_message(subscription, details) do
    message = format_message(details, subscription)

    if subscription.alert_image_url do
      send_message_with_image(subscription, message)
    else
      @telegram_client.send_message(subscription.chat_id, message)
    end

    :ok
  end

  defp send_message_with_image(subscription, message) do
    if valid_url?(subscription.alert_image_url) do
      if String.contains?(subscription.alert_image_url, ".gif") or String.contains?(subscription.alert_image_url, ".mp4") do
        case @telegram_client.send_animation(subscription.chat_id, subscription.alert_image_url, message) do
          :ok ->
            :ok

          {:error, reason} ->
            handle_animation_error(subscription.creator_id, subscription.chat_id, reason)
            @telegram_client.send_message(subscription.chat_id, message)
        end
      else
        case @telegram_client.send_photo(subscription.chat_id, subscription.alert_image_url, message) do
          :ok -> :ok
          {:error, reason} -> handle_photo_error(subscription.creator_id, subscription.chat_id, reason, message)
        end
      end
    else
      Logger.error("Invalid URL for alert image: #{subscription.alert_image_url}")
      @telegram_client.send_message(subscription.chat_id, message)
    end
  end

  defp handle_photo_error(owner_chat_id, chat_id, reason, message) do
    error_message = "Failed to send photo to #{chat_id}: #{inspect(reason)}"
    Logger.error(error_message)
    @telegram_client.send_message(owner_chat_id, error_message)
    @telegram_client.send_message(chat_id, message)
  end

  defp handle_animation_error(owner_chat_id, chat_id, reason) do
    error_message = "Failed to send animation to #{chat_id}: #{inspect(reason)}"
    Logger.error(error_message)
    @telegram_client.send_message(owner_chat_id, error_message)
  end

  defp valid_url?(url) do
    case :httpc.request(:head, {to_charlist(url), []}, [], []) do
      {:ok, _response} -> true
      {:error, _reason} -> false
    end
  end

  defp process_notification(notification) do
    details = %{
      id: notification["id"],
      caller: notification["caller"],
      token_in: notification["token_in"],
      token_in_sym: notification["token_in_sym"],
      token_out: notification["token_out"],
      token_out_sym: notification["token_out_sym"],
      token_amount_in: Decimal.new(Kernel.to_string(notification["token_amount_in"])),
      token_amount_out: Decimal.new(Kernel.to_string(notification["token_amount_out"])),
      value_usd: Decimal.new(Kernel.to_string(notification["value_usd"])),
      pool_id: notification["pool_id"],
      user_address: notification["user_address"],
      block: notification["block"],
      tx: notification["tx"],
      chain_id: notification["chain_id"],
      dexscreener_url: notification["dexscreener_url"],
      tx_link: notification["tx_link"],
      buy_link: notification["buy_link"],
      deposit_link: notification["deposit_link"],
      updated_at: notification["updated_at"]
    }

    {:ok, details}
  rescue
    e in ArgumentError ->
      Logger.error("Invalid data in notification payload: #{inspect(e)}")
      {:error, :invalid_data}
  end

  defp broadcast(details) do
    Logger.debug("Broadcasting notification: #{inspect(details)}")

    broadcast_to_subscribers(details)
  end

  defp broadcast_to_subscribers(details) do
    case ChatSubscriptionManager.list_subscriptions() do
      subscriptions when is_list(subscriptions) ->
        Enum.each(subscriptions, fn subscription ->
          if should_notify?(details, subscription) do
            send_message(subscription, details)
          else
            Logger.debug("Notification does not match subscription criteria: #{inspect(subscription)}")
          end
        end)

      _ ->
        Logger.info("No subscriptions found")
        :ok
    end

    :ok
  end

  defp should_notify?(details, subscription) do
    subscription.paused == false &&
      same_token?(details, subscription) &&
      token_out_larger_than_min_buy_amount?(details, subscription)
  end

  defp same_token?(details, subscription) do
    details.token_out == subscription.token_address &&
      details.chain_id == subscription.chain_id
  end

  defp token_out_larger_than_min_buy_amount?(details, subscription) do
    token_amount_out = Decimal.new(Kernel.to_string(details.token_amount_out))
    min_buy_amount = Decimal.new(Kernel.to_string(subscription.min_buy_amount))

    case Decimal.compare(token_amount_out, min_buy_amount) do
      :gt -> true
      :eq -> true
      _ -> false
    end
  end

  def format_message(details, subscription) do
    token_out_in_usd = Decimal.div(details.value_usd, details.token_amount_out)
    # Set default language to "en" if nil
    language = subscription.language || "en"

    Gettext.put_locale(language)

    message = """
    *#{details.token_out_sym} PURCHASED!*
    #{format_trade_size_emoji(details.token_amount_out, subscription.trade_size_emoji, subscription.trade_size_step)}
    #{gettext("Spent")}: `#{humanize_value(details.token_amount_in)} #{details.token_in_sym}`
    #{gettext("Bought")}: `#{humanize_value(details.token_amount_out)} #{details.token_out_sym} ($#{humanize_value(details.value_usd)})`
    #{gettext("Price")}: `1 #{details.token_out_sym} = $ #{humanize_value(token_out_in_usd)}`
    #{format_links(subscription, details)}
    """

    if String.length(message) > 4096 do
      ^message = trim_emojis(message, subscription.trade_size_emoji)
    end

    message
  end

  defp trim_emojis(message, emoji) do
    trimmed_message = String.replace(message, emoji, "", global: false)

    if String.length(trimmed_message) > 4096 do
      trim_emojis(trimmed_message, emoji)
    else
      trimmed_message
    end
  end

  def humanize_value(value) do
    add_thousand_separator(Decimal.to_string(Decimal.round(value, 6), :normal))
  end

  def add_thousand_separator(number) when is_binary(number) do
    parts = String.split(number, ".", parts: 2)
    integer_part = Enum.at(parts, 0)
    decimal_part = Enum.at(parts, 1, "")

    reversed_integer_part = String.reverse(integer_part)

    formatted_integer_part = Regex.replace(~r/(\d{3})(?=\d)/, reversed_integer_part, "\\1,")

    formatted_integer_part = String.reverse(formatted_integer_part)

    case decimal_part do
      "" -> formatted_integer_part
      _ -> formatted_integer_part <> "." <> decimal_part
    end
  end

  def add_thousand_separator(number) when is_struct(number, Decimal) do
    number_string = Decimal.to_string(number)
    add_thousand_separator(number_string)
  end

  defp format_trade_size_emoji(token_amount, emoji, step) do
    steps = Decimal.div(token_amount, Decimal.new(step))
    rounded_steps = Decimal.round(steps, 0)
    emoji_string = String.duplicate(emoji, Decimal.to_integer(rounded_steps))
    "#{emoji_string}"
  end

  defp get_link_url(link_id, subscription, details) do
    case link_id do
      "tx" -> details.tx_link
      "buy" -> details.buy_link
      "deposit" -> details.deposit_link
      "chart" -> details.dexscreener_url
      _ -> subscription.links |> Enum.find(fn link -> link["label"] == link_id end) |> Map.get("url")
    end
  end

  defp get_enabled_links(links) do
    Enum.filter(links, fn link -> link["status"] == "enabled" end)
  end

  defp format_links(subscription, details) do
    Logger.debug("Formatting links for subscription: #{inspect(subscription)}")

    subscription.links
    |> get_enabled_links()
    |> Enum.map(fn link ->
      format_link(link["label"], get_link_url(link["id"], subscription, details))
    end)
    |> Enum.filter(&(&1 != ""))
    |> Enum.join(" | ")
  end

  defp format_link(label, url) when url != nil and url != "" do
    "[#{label}](#{url})"
  end

  defp format_link(_label, _url), do: ""
end
