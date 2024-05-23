defmodule SwapListener.NotificationService do
  @moduledoc false

  alias SwapListener.BlockchainConfig
  alias SwapListener.ChatSubscriptionManager

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
      @telegram_client.send_photo(subscription.chat_id, subscription.alert_image_url, message)
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
         "dexscreener_url" => dexscreener_url
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
      dexscreener_url: dexscreener_url,
      pool_id: pool_id,
      user_address: user_address,
      block: block,
      tx: tx,
      chain_id: chain_id
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
        Logger.debug("Found subscriptions: #{inspect(subscriptions)}")

        Enum.each(subscriptions, fn subscription ->
          Logger.debug("Broadcasting to chat_id: #{subscription.chat_id} \
                        with settings: #{inspect(subscription)} \
                        and details: #{inspect(details)}")

          if should_notify?(details, subscription) do
            @telegram_client.send_message(subscription.chat_id, format_message(details, subscription))
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
      details.chain_id == subscription.chain_id &&
      details.token_out == subscription.token_address && details.token_amount_out >= subscription.min_buy_amount
  end

  defp format_message(details, subscription) do
    token_out_in_usd = Decimal.div(details.value_usd, details.token_amount_out)

    """
    *#{details.token_out_sym} PURCHASED!*
    Spent: `#{humanize_value(details.token_amount_in)} #{details.token_in_sym}`
    Bought: `#{humanize_value(details.token_amount_out)} #{details.token_out_sym} ($#{humanize_value(details.value_usd)})`
    Price: `1 #{details.token_out_sym} = $ #{humanize_value(token_out_in_usd)}`
    [Transaction](#{get_explorer_link(details.chain_id, details.tx)}) | [Balancer Pool](#{get_pool_link(details.chain_id, details.pool_id)}) | #{format_link("DEX Screener", details.dexscreener_url)}
    #{format_links(subscription)}
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

  defp format_links(subscription) do
    [
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

  defp get_explorer_link(chain_id, tx_hash) do
    base_url = Map.get(BlockchainConfig.chain_scanner_map(), chain_id, "https://etherscan.io")
    "#{base_url}/tx/#{tx_hash}"
  end

  defp get_pool_link(chain_id, pool_id) do
    base_url =
      Map.get(
        BlockchainConfig.balancer_pool_map(),
        chain_id,
        "https://pools.balancer.exchange/#/pool/"
      )

    "#{base_url}#{pool_id}"
  end

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
      value_usd: "5000.0"
    }

    test_subscription = %{
      chat_id: chat_id,
      token_address: notification.token_out,
      chain_id: notification.chain_id,
      alert_image_url: "https://picsum.photos/536/354",
      website_url: nil,
      twitter_handle: nil,
      discord_link: nil,
      telegram_link: nil
    }

    send_message(test_subscription, notification)
  end
end
