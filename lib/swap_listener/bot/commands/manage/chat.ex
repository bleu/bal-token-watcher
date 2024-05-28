defmodule SwapListener.Bot.Commands.Manage.Chat do
  @moduledoc false
  alias SwapListener.Bot.Commands.Utils
  alias SwapListener.ChatSubscription.ChatSubscriptionManager
  alias SwapListener.Common.BlockchainConfig
  alias SwapListener.Telegram.TelegramClientImpl

  def prompt(managed_chat_str, this_chat_id, state) do
    chat_id = String.to_integer(managed_chat_str)
    subscriptions = ChatSubscriptionManager.list_subscriptions_from_chat(chat_id)
    buttons = build_subscription_buttons(subscriptions)
    reply_markup = %{inline_keyboard: buttons}

    case TelegramClientImpl.get_chat(chat_id) do
      {:ok, %{"title" => chat_title}} ->
        reply = %{
          chat_id: this_chat_id,
          text: "Manage your subscriptions in chat **#{chat_title}**:",
          reply_markup: reply_markup
        }

        {state, reply}
    end
  end

  defp build_subscription_buttons(subscriptions) do
    Enum.map(subscriptions, fn subscription ->
      token_label = Utils.build_token_label(subscription.token_address, subscription.chain_id)
      chain_label = BlockchainConfig.get_chain_label(subscription.chain_id)
      status = if subscription.paused, do: "Paused", else: "Active"
      display_label = "#{chain_label}, #{token_label}, #{status}"
      [%{text: display_label, callback_data: "manage_subscription:#{subscription.id}"}]
    end)
  end
end
