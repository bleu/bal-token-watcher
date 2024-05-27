defmodule SwapListener.Bot.Commands.Manage.All do
  @moduledoc false
  alias SwapListener.ChatSubscription.ChatSubscriptionManager

  def pause_all(chat_id, state) do
    ChatSubscriptionManager.pause_all(chat_id)
    {state, %{text: "All subscriptions have been paused.", chat_id: chat_id}}
  end

  def restart_all(chat_id, state) do
    ChatSubscriptionManager.restart_all(chat_id)
    {state, %{text: "All subscriptions have been restarted.", chat_id: chat_id}}
  end

  def unsubscribe_all(chat_id, state) do
    ChatSubscriptionManager.unsubscribe_all(chat_id)
    {state, %{text: "All subscriptions have been unsubscribed.", chat_id: chat_id}}
  end
end
