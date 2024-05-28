defmodule SwapListener.Bot.Commands.Manage.Chat.Subscription do
  @moduledoc false
  alias SwapListener.ChatSubscription.ChatSubscriptionManager

  def prompt(subscription_id, chat_id, state) do
    state = Map.put(state, :current_subscription, subscription_id)

    buttons = [
      [
        %{text: "Pause", callback_data: "pause_subscription:#{subscription_id}"},
        %{text: "Restart", callback_data: "restart_subscription:#{subscription_id}"},
        %{text: "Unsubscribe", callback_data: "unsubscribe_subscription:#{subscription_id}"}
      ],
      [
        %{text: "Manage Links", callback_data: "manage_links:#{subscription_id}"},
        %{text: "Change Settings", callback_data: "change_settings:#{subscription_id}"}
      ]
    ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage subscription:",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def pause(subscription_id, chat_id, state) do
    case ChatSubscriptionManager.pause_subscription(subscription_id) do
      :ok -> {state, %{chat_id: chat_id, text: "Subscription paused."}}
      {:error, reason} -> {state, %{chat_id: chat_id, text: "Failed to pause subscription: #{reason}"}}
    end
  end

  def restart(subscription_id, chat_id, state) do
    case ChatSubscriptionManager.restart_subscription(subscription_id) do
      :ok -> {state, %{chat_id: chat_id, text: "Subscription restarted."}}
      {:error, reason} -> {state, %{chat_id: chat_id, text: "Failed to restart subscription: #{reason}"}}
    end
  end

  def unsubscribe(subscription_id, chat_id, state) do
    case ChatSubscriptionManager.unsubscribe(subscription_id) do
      :ok -> {state, %{chat_id: chat_id, text: "Unsubscribed successfully."}}
      {:error, reason} -> {state, %{chat_id: chat_id, text: "Failed to unsubscribe: #{reason}"}}
    end
  end
end
