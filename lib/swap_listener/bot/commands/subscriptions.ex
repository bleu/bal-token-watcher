defmodule SwapListener.Bot.Commands.Subscriptions do
  @moduledoc false
  alias SwapListener.Bot.Commands.Utils
  alias SwapListener.ChatSubscription.ChatSubscriptionManager

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  def handle(chat_id, user_id, _args, state) do
    list_subscriptions(chat_id, user_id)
    {state, nil}
  end

  defp list_subscriptions(chat_id, user_id) do
    case ChatSubscriptionManager.list_subscriptions_from_user(user_id) do
      [] ->
        @telegram_client.send_message(chat_id, "You are not subscribed to any tokens.")

      subscriptions when is_list(subscriptions) ->
        message = Utils.format_subscription_table(subscriptions)
        @telegram_client.send_message(chat_id, message)

      _ ->
        @telegram_client.send_message(chat_id, "Failed to fetch subscriptions.")
    end
  end
end
