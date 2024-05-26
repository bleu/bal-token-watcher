defmodule SwapListener.Bot.Commands.Manage do
  @moduledoc false
  alias SwapListener.Bot.Commands.Utils
  alias SwapListener.ChatSubscription.ChatSubscriptionManager
  alias SwapListener.Common.BlockchainConfig

  def handle(chat_id, user_id, _args, state) do
    subscriptions = ChatSubscriptionManager.list_subscriptions_from_user(user_id)
    buttons = build_subscription_buttons(subscriptions)
    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage your subscriptions:",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  defp build_subscription_buttons(subscriptions) do
    subscription_buttons =
      Enum.map(subscriptions, fn subscription ->
        token_label = Utils.token_address_with_sym(subscription.token_address, subscription.chain_id)
        chain_label = BlockchainConfig.get_chain_label(subscription.chain_id)
        status = if subscription.paused, do: "Paused", else: "Active"

        display_label =
          "#{chain_label}, #{token_label}, #{status}"

        [%{text: display_label, callback_data: "manage_subscription:#{subscription.id}"}]
      end)

    all_actions_buttons = [
      [%{text: "Pause All", callback_data: "pauseall"}],
      [%{text: "Restart All", callback_data: "restartall"}],
      [%{text: "Unsubscribe All", callback_data: "unsubscribeall"}]
    ]

    subscription_buttons ++ all_actions_buttons
  end

  def handle_callback_query("manage_subscription:" <> subscription_id, chat_id, _user_id, state) do
    state = Map.put(state, :current_subscription, subscription_id)

    buttons = [
      [%{text: "Pause", callback_data: "pause_subscription:#{subscription_id}"}],
      [%{text: "Restart", callback_data: "restart_subscription:#{subscription_id}"}],
      [%{text: "Unsubscribe", callback_data: "unsubscribe_subscription:#{subscription_id}"}],
      [%{text: "Change Settings", callback_data: "change_settings:#{subscription_id}"}]
    ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage subscription:",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def handle_callback_query("change_settings:" <> subscription_id, chat_id, _user_id, state) do
    state = Map.put(state, :current_subscription, subscription_id)

    # Add the necessary steps to update subscription settings
    new_state = Map.put(state, :step, :select_setting)

    buttons = [
      [%{text: "Min Buy Amount", callback_data: "update_min_buy_amount:#{subscription_id}"}],
      [%{text: "Trade Size Emoji", callback_data: "update_trade_size_emoji:#{subscription_id}"}],
      [%{text: "Trade Size Step", callback_data: "update_trade_size_step:#{subscription_id}"}],
      [%{text: "Alert Image URL", callback_data: "update_alert_image_url:#{subscription_id}"}],
      [%{text: "Website URL", callback_data: "update_website_url:#{subscription_id}"}],
      [%{text: "Twitter Handle", callback_data: "update_twitter_handle:#{subscription_id}"}],
      [%{text: "Discord Link", callback_data: "update_discord_link:#{subscription_id}"}],
      [%{text: "Telegram Link", callback_data: "update_telegram_link:#{subscription_id}"}]
    ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Select the setting you want to update:",
      reply_markup: reply_markup
    }

    {new_state, reply}
  end

  # Add functions to handle each specific setting update:
  def handle_callback_query("update_min_buy_amount:" <> _subscription_id, chat_id, _user_id, state) do
    new_state = Map.put(state, :step, :min_buy_amount)
    reply = %{chat_id: chat_id, text: "Please enter the new minimum buy amount:"}
    {new_state, reply}
  end

  def handle_callback_query("update_trade_size_emoji:" <> _subscription_id, chat_id, _user_id, state) do
    new_state = Map.put(state, :step, :trade_size_emoji)
    reply = %{chat_id: chat_id, text: "Please enter the new trade size emoji:"}
    {new_state, reply}
  end

  def handle_callback_query("update_trade_size_step:" <> _subscription_id, chat_id, _user_id, state) do
    new_state = Map.put(state, :step, :trade_size_step)
    reply = %{chat_id: chat_id, text: "Please enter the new trade size step:"}
    {new_state, reply}
  end

  def handle_callback_query("update_alert_image_url:" <> _subscription_id, chat_id, _user_id, state) do
    new_state = Map.put(state, :step, :alert_image_url)
    reply = %{chat_id: chat_id, text: "Please enter the new alert image URL:"}
    {new_state, reply}
  end

  def handle_callback_query("update_website_url:" <> _subscription_id, chat_id, _user_id, state) do
    new_state = Map.put(state, :step, :website_url)
    reply = %{chat_id: chat_id, text: "Please enter the new website URL:"}
    {new_state, reply}
  end

  def handle_callback_query("update_twitter_handle:" <> _subscription_id, chat_id, _user_id, state) do
    new_state = Map.put(state, :step, :twitter_handle)
    reply = %{chat_id: chat_id, text: "Please enter the new Twitter handle:"}
    {new_state, reply}
  end

  def handle_callback_query("update_discord_link:" <> _subscription_id, chat_id, _user_id, state) do
    new_state = Map.put(state, :step, :discord_link)
    reply = %{chat_id: chat_id, text: "Please enter the new Discord link:"}
    {new_state, reply}
  end

  def handle_callback_query("update_telegram_link:" <> _subscription_id, chat_id, _user_id, state) do
    new_state = Map.put(state, :step, :telegram_link)
    reply = %{chat_id: chat_id, text: "Please enter the new Telegram link:"}
    {new_state, reply}
  end
end
