defmodule SwapListener.CommandHandler.Unsubscribe do
  @moduledoc false
  alias SwapListener.ChatSubscriptionManager
  alias SwapListener.CommandHandler.Utils

  @telegram_client Application.compile_env(:swap_listener, :telegram_client, SwapListener.RateLimitedTelegramClientImpl)

  def handle(chat_id, args, state) do
    case args do
      [token_address, chain_id] ->
        parsed_chain_id = String.to_integer(chain_id)
        ChatSubscriptionManager.unsubscribe(chat_id, token_address, parsed_chain_id)
        {state, nil}

      _ ->
        @telegram_client.send_message(
          chat_id,
          "Please provide a token address and chain ID to unsubscribe. Here are your current subscriptions:"
        )

        list_subscriptions(chat_id)

        {state, nil}
    end
  end

  @spec handle_all(any(), any(), any()) :: {any(), nil}
  def handle_all(chat_id, _args, state) do
    ChatSubscriptionManager.unsubscribe(chat_id)
    {state, nil}
  end

  defp list_subscriptions(chat_id) do
    case ChatSubscriptionManager.list_subscriptions(chat_id) do
      [] ->
        @telegram_client.send_message(chat_id, "You are not subscribed to any tokens.")

      subscriptions when is_list(subscriptions) ->
        message = Utils.format_subscription_list(subscriptions)
        @telegram_client.send_message(chat_id, message)

      _ ->
        @telegram_client.send_message(chat_id, "Failed to fetch subscriptions.")
    end
  end
end
