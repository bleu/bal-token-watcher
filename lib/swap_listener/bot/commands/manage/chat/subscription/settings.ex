defmodule SwapListener.Bot.Commands.Manage.Chat.Subscription.Settings do
  @moduledoc false
  def prompt(subscription_id, chat_id, state) do
    state = Map.put(state, :current_subscription, subscription_id)

    buttons = [
      [%{text: "Min Buy Amount", callback_data: "update_min_buy_amount:#{subscription_id}"}],
      [%{text: "Trade Size Emoji", callback_data: "update_trade_size_emoji:#{subscription_id}"}],
      [%{text: "Trade Size Step", callback_data: "update_trade_size_step:#{subscription_id}"}],
      [%{text: "Edit Links", callback_data: "edit_links:#{subscription_id}"}]
    ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Select the setting you want to update:",
      reply_markup: reply_markup
    }

    {state, reply}
  end
end
