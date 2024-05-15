defmodule SwapListener.NotificationService do
  alias SwapListener.{ChatSubscriptionManager, BalancerSwap, TelegramClient, BlockchainConfig}
  require Logger
  require IEx

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

  defp process_notification(%{
         "block" => block,
         "caller" => caller,
         "chain_id" => chain_id,
         "id" => id,
         "inserted_at" => _,
         "pool_id" => pool_id,
         "timestamp" => timestamp,
         "token_amount_in" => token_amount_in,
         "token_amount_out" => token_amount_out,
         "token_in" => token_in,
         "token_in_sym" => token_in_sym,
         "token_out" => token_out,
         "token_out_sym" => token_out_sym,
         "tx" => tx,
         "updated_at" => _,
         "user_address" => user_address,
         "value_usd" => value_usd
       }) do
    Logger.debug(
      "Processing notification details: #{inspect(%{id: id, caller: caller, token_in: token_in, token_in_sym: token_in_sym, token_out: token_out, token_out_sym: token_out_sym, token_amount_in: token_amount_in, token_amount_out: token_amount_out, value_usd: value_usd, pool_id: pool_id, user_address: user_address, timestamp: timestamp, block: block, tx: tx, chain_id: chain_id})}"
    )

    details = %{
      id: id,
      caller: caller,
      token_in: token_in,
      token_in_sym: token_in_sym,
      token_out: token_out,
      token_out_sym: token_out_sym,
      token_amount_in: Decimal.new(to_string(token_amount_in)),
      token_amount_out: Decimal.new(to_string(token_amount_out)),
      value_usd: Decimal.new(to_string(value_usd)),
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
    Logger.info("Broadcasting notification: #{inspect(details)}")

    case ChatSubscriptionManager.list_subscriptions() do
      subscriptions when is_list(subscriptions) ->
        Logger.info("Found subscriptions: #{inspect(subscriptions)}")

        Enum.each(subscriptions, fn subscription ->
          Logger.info("Broadcasting to chat_id: #{subscription.chat_id} \
                        with settings: #{inspect(subscription)} \
                        and details: #{inspect(details)}")

          if should_notify?(details, subscription) do
            message = format_message(details, subscription)
            TelegramClient.send_message(subscription.chat_id, message)
          else
            Logger.info(
              "Notification does not match subscription criteria: #{inspect(subscription)}"
            )
          end
        end)

      _ ->
        Logger.info("No subscriptions found")
        :ok
    end

    :ok
  end

  defp should_notify?(details, subscription) do
    details.chain_id == subscription.chain_id &&
      details.token_out == subscription.token_address
  end

  defp format_message(details, subscription) do
    """
    #{subscription.alert_image_url}
    *#{details.token_out_sym} PURCHASED!*

    Spent: `#{details.token_amount_in} #{details.token_in_sym}`
    Bought: `#{details.token_amount_out} #{details.token_out_sym}`
    [Transaction](#{get_explorer_link(details.chain_id, details.tx)}) | [Balancer Pool](#{get_pool_link(details.chain_id, details.pool_id)})
    More Info: #{format_links(subscription)}
    """
  end

  defp format_links(subscription) do
    Enum.map(
      [:website_url, :twitter_handle, :discord_link, :telegram_link],
      fn key ->
        if link = subscription[key], do: "[#{Atom.to_string(key)}](#{link})", else: ""
      end
    )
    |> Enum.filter(&(&1 != ""))
    |> Enum.join(" | ")
  end

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
end
