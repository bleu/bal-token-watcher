defmodule SwapListener.NotificationService do
  @moduledoc false

  alias SwapListener.ChatSubscriptionManager

  require Decimal
  require Logger

  @telegram_client Application.compile_env(:swap_listener, :telegram_client, SwapListener.RateLimitedTelegramClientImpl)

  def handle_notification(notification) do
    Logger.debug("Handling notification: #{inspect(notification)}")

    with {:ok, details} <- process_notification(notification),
         :ok <- broadcast(details) do
      Logger.debug("Notification processed and broadcast successfully")
    else
      error ->
        Logger.error("Failed to process notification: #{inspect(error)}")
    end
  end

  defp send_message(subscription, details) do
    message = format_message(details, subscription)

    if subscription.alert_image_url do
      if String.contains?(subscription.alert_image_url, ".gif") do
        @telegram_client.send_animation(subscription.chat_id, subscription.alert_image_url, message)
      else
        @telegram_client.send_photo(subscription.chat_id, subscription.alert_image_url, message)
      end
    else
      @telegram_client.send_message(subscription.chat_id, message)
    end

    :ok
  end

  defp process_notification(%{
         "block" => block,
         "caller" => caller,
         "chain_id" => chain_id,
         "id" => id,
         "inserted_at" => _,
         "pool_id" => pool_id,
         "timestamp" => _timestamp,
         "token_amount_in" => token_amount_in,
         "token_amount_out" => token_amount_out,
         "token_in" => token_in,
         "token_in_sym" => token_in_sym,
         "token_out" => token_out,
         "token_out_sym" => token_out_sym,
         "tx" => tx,
         "updated_at" => _,
         "user_address" => user_address,
         "value_usd" => value_usd,
         "dexscreener_url" => dexscreener_url,
         "tx_link" => tx_link,
         "buy_link" => buy_link,
         "deposit_link" => deposit_link
       }) do
    details = %{
      id: id,
      caller: caller,
      token_in: token_in,
      token_in_sym: token_in_sym,
      token_out: token_out,
      token_out_sym: token_out_sym,
      token_amount_in: Decimal.new(Kernel.to_string(token_amount_in)),
      token_amount_out: Decimal.new(Kernel.to_string(token_amount_out)),
      value_usd: Decimal.new(Kernel.to_string(value_usd)),
      pool_id: pool_id,
      user_address: user_address,
      block: block,
      tx: tx,
      chain_id: chain_id,
      dexscreener_url: dexscreener_url,
      tx_link: tx_link,
      buy_link: buy_link,
      deposit_link: deposit_link
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

  defp format_message(details, subscription) do
    token_out_in_usd = Decimal.div(details.value_usd, details.token_amount_out)

    """
    *#{details.token_out_sym} PURCHASED!*
    Spent: `#{humanize_value(details.token_amount_in)} #{details.token_in_sym}`
    Bought: `#{humanize_value(details.token_amount_out)} #{details.token_out_sym} ($#{humanize_value(details.value_usd)})`
    Price: `1 #{details.token_out_sym} = $ #{humanize_value(token_out_in_usd)}`
    #{format_links(subscription, details)}
    """
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

  defp format_links(subscription, details) do
    [
      format_link("TX", details.tx_link),
      format_link("Buy", details.buy_link),
      format_link("LP", details.deposit_link),
      format_link("Chart", details.dexscreener_url),
      format_link("Website", subscription.website_url),
      format_link("Twitter", subscription.twitter_handle),
      format_link("Discord", subscription.discord_link),
      format_link("Telegram", subscription.telegram_link)
    ]
    |> Enum.filter(&(&1 != ""))
    |> Enum.join(" | ")
  end

  defp format_link(label, url) when url != nil and url != "" do
    "[#{label}](#{url})"
  end

  defp format_link(_label, _url), do: ""

  # Use to trigger a test notification to a specific chat_id
  # SwapListener.NotificationService.send_test_notification(chat_id)
  def send_test_notification(chat_id) do
    notification = %{
      block: 123_456,
      caller: "0x1234567890abcdef",
      chain_id: 1,
      id: "0xabcdef1234567890",
      inserted_at: nil,
      pool_id: "0xpoolid123456",
      timestamp: DateTime.to_unix(DateTime.utc_now()),
      token_amount_in: "100.0",
      token_amount_out: "50.0",
      token_in: "0xtokenin123456",
      token_in_sym: "ETH",
      token_out: "0xtokenout123456",
      token_out_sym: "DAI",
      tx: "0xtx1234567890abcdef",
      updated_at: nil,
      user_address: "0xuseraddress123456",
      value_usd: "5000.0",
      dexscreener_url: "https://dexscreener.com",
      tx_link: "https://etherscan.io/tx/0xtx1234567890abcdef",
      buy_link: "https://app.1inch.io/#/1/simple/swap/0xtokenin123456/0xtokenout123456",
      deposit_link: "https://app.1inch.io/#/1/pool/0xpoolid123456"
    }

    test_subscription = %{
      chat_id: chat_id,
      token_address: notification.token_out,
      chain_id: notification.chain_id,
      alert_image_url:
        "https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExdnlpMTU2b3B5Nmlhajl2Y2Z3dnQwdG5zZzZpNHpzamlsa29taGxrZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3orieS4jfHJaKwkeli/giphy.gif",
      website_url: "https://example.com",
      twitter_handle: "https://example.com",
      discord_link: "https://example.com",
      telegram_link: "https://example.com"
    }

    send_message(test_subscription, notification)
  end
end
