defmodule SwapListener.Bot.Commands.Manage do
  @moduledoc false
  alias SwapListener.Bot.Commands.Utils
  alias SwapListener.ChatSubscription.ChatSubscriptionManager
  alias SwapListener.Common.BlockchainConfig
  alias SwapListener.Telegram.TelegramClientImpl

  def handle(chat_id, user_id, _args, state) do
    subscriptions = ChatSubscriptionManager.list_subscriptions_from_user(user_id)
    chats = extract_chats_with_titles(subscriptions)
    buttons = build_chat_buttons(chats)
    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Select a chat to manage your subscriptions:",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def handle_callback_query(data, chat_id, _user_id, state) do
    case String.split(data, ":") do
      ["pauseall"] -> pause_all(chat_id, state)
      ["restartall"] -> restart_all(chat_id, state)
      ["unsubscribeall"] -> unsubscribe_all(chat_id, state)
      ["manage_chat", managed_chat_str] -> manage_chat(managed_chat_str, chat_id, state)
      ["manage_subscription", subscription_id] -> manage_subscription(subscription_id, chat_id, state)
      ["pause_subscription", subscription_id] -> pause_subscription(subscription_id, chat_id, state)
      ["restart_subscription", subscription_id] -> restart_subscription(subscription_id, chat_id, state)
      ["unsubscribe_subscription", subscription_id] -> unsubscribe_subscription(subscription_id, chat_id, state)
      ["change_settings", subscription_id] -> change_settings(subscription_id, chat_id, state)
      ["update_min_buy_amount", subscription_id] -> update_min_buy_amount(subscription_id, chat_id, state)
      ["update_trade_size_emoji", subscription_id] -> update_trade_size_emoji(subscription_id, chat_id, state)
      ["update_trade_size_step", subscription_id] -> update_trade_size_step(subscription_id, chat_id, state)
      ["update_alert_image_url", subscription_id] -> update_alert_image_url(subscription_id, chat_id, state)
      ["update_website_url", subscription_id] -> update_website_url(subscription_id, chat_id, state)
      ["update_twitter_handle", subscription_id] -> update_twitter_handle(subscription_id, chat_id, state)
      ["update_discord_link", subscription_id] -> update_discord_link(subscription_id, chat_id, state)
      ["update_telegram_link", subscription_id] -> update_telegram_link(subscription_id, chat_id, state)
      ["update_language", subscription_id] -> update_language(subscription_id, chat_id, state)
      ["set_language", data] -> set_language(data, chat_id, state)
      _ -> {state, %{chat_id: chat_id, text: "Unknown action."}}
    end
  end

  defp pause_all(chat_id, state) do
    ChatSubscriptionManager.pause_all(chat_id)
    {state, %{text: "All subscriptions have been paused.", chat_id: chat_id}}
  end

  defp restart_all(chat_id, state) do
    ChatSubscriptionManager.restart_all(chat_id)
    {state, %{text: "All subscriptions have been restarted.", chat_id: chat_id}}
  end

  defp unsubscribe_all(chat_id, state) do
    ChatSubscriptionManager.unsubscribe_all(chat_id)
    {state, %{text: "All subscriptions have been unsubscribed.", chat_id: chat_id}}
  end

  defp manage_chat(managed_chat_str, this_chat_id, state) do
    chat_id = String.to_integer(managed_chat_str)
    subscriptions = ChatSubscriptionManager.list_subscriptions_from_chat(chat_id)
    buttons = build_subscription_buttons(subscriptions)
    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: this_chat_id,
      text: "Manage your subscriptions in chat #{chat_id}:",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  defp manage_subscription(subscription_id, chat_id, state) do
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

  defp pause_subscription(subscription_id, chat_id, state) do
    case ChatSubscriptionManager.pause_subscription(subscription_id) do
      :ok -> {state, %{chat_id: chat_id, text: "Subscription paused."}}
      {:error, reason} -> {state, %{chat_id: chat_id, text: "Failed to pause subscription: #{reason}"}}
    end
  end

  defp restart_subscription(subscription_id, chat_id, state) do
    case ChatSubscriptionManager.restart_subscription(subscription_id) do
      :ok -> {state, %{chat_id: chat_id, text: "Subscription restarted."}}
      {:error, reason} -> {state, %{chat_id: chat_id, text: "Failed to restart subscription: #{reason}"}}
    end
  end

  defp unsubscribe_subscription(subscription_id, chat_id, state) do
    case ChatSubscriptionManager.unsubscribe(subscription_id) do
      :ok -> {state, %{chat_id: chat_id, text: "Unsubscribed successfully."}}
      {:error, reason} -> {state, %{chat_id: chat_id, text: "Failed to unsubscribe: #{reason}"}}
    end
  end

  defp change_settings(subscription_id, chat_id, state) do
    state = Map.put(state, :current_subscription, subscription_id)

    buttons = [
      [%{text: "Min Buy Amount", callback_data: "update_min_buy_amount:#{subscription_id}"}],
      [%{text: "Trade Size Emoji", callback_data: "update_trade_size_emoji:#{subscription_id}"}],
      [%{text: "Trade Size Step", callback_data: "update_trade_size_step:#{subscription_id}"}],
      [%{text: "Alert Image URL", callback_data: "update_alert_image_url:#{subscription_id}"}],
      [%{text: "Website URL", callback_data: "update_website_url:#{subscription_id}"}],
      [%{text: "Twitter Handle", callback_data: "update_twitter_handle:#{subscription_id}"}],
      [%{text: "Discord Link", callback_data: "update_discord_link:#{subscription_id}"}],
      [%{text: "Telegram Link", callback_data: "update_telegram_link:#{subscription_id}"}],
      [%{text: "Language", callback_data: "update_language:#{subscription_id}"}]
    ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Select the setting you want to update:",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  defp update_min_buy_amount(subscription_id, chat_id, state) do
    set_step(state, chat_id, :min_buy_amount, subscription_id, "Please enter the new minimum buy amount:")
  end

  defp update_trade_size_emoji(subscription_id, chat_id, state) do
    set_step(state, chat_id, :trade_size_emoji, subscription_id, "Please enter the new trade size emoji:")
  end

  defp update_trade_size_step(subscription_id, chat_id, state) do
    set_step(state, chat_id, :trade_size_step, subscription_id, "Please enter the new trade size step:")
  end

  defp update_alert_image_url(subscription_id, chat_id, state) do
    set_step(state, chat_id, :alert_image_url, subscription_id, "Please enter the new alert image URL:")
  end

  defp update_website_url(subscription_id, chat_id, state) do
    set_step(state, chat_id, :website_url, subscription_id, "Please enter the new website URL:")
  end

  defp update_twitter_handle(subscription_id, chat_id, state) do
    set_step(state, chat_id, :twitter_handle, subscription_id, "Please enter the new Twitter handle:")
  end

  defp update_discord_link(subscription_id, chat_id, state) do
    set_step(state, chat_id, :discord_link, subscription_id, "Please enter the new Discord link:")
  end

  defp update_telegram_link(subscription_id, chat_id, state) do
    set_step(state, chat_id, :telegram_link, subscription_id, "Please enter the new Telegram link:")
  end

  defp update_language(subscription_id, chat_id, state) do
    handle_language_selection(subscription_id, chat_id, state)
  end

  defp set_language(data, chat_id, state) do
    handle_language_update(data, chat_id, state)
  end

  defp set_step(state, chat_id, step, subscription_id, text) do
    new_state = Map.put(state, :step, step)
    new_state = Map.put(new_state, :current_subscription, subscription_id)
    reply = %{chat_id: chat_id, text: text}
    {new_state, reply}
  end

  defp handle_language_selection(subscription_id, chat_id, state) do
    languages = %{
      "en" => "English",
      "zh" => "Chinese (中文)",
      "ko" => "Korean (한국어)",
      "es" => "Spanish (Español)",
      "ja" => "Japanese (日本語)",
      "pt" => "Portuguese (Português)",
      "fr" => "French (Français)",
      "ru" => "Russian (Русский)",
      "de" => "German (Deutsch)",
      "it" => "Italian (Italiano)",
      "pl" => "Polish (Polski)",
      "nl" => "Dutch (Nederlands)"
    }

    buttons =
      Enum.map(languages, fn {code, name} -> [%{text: name, callback_data: "set_language:#{code}:#{subscription_id}"}] end)

    reply_markup = %{inline_keyboard: buttons}
    reply = %{chat_id: chat_id, text: "Select your preferred language:", reply_markup: reply_markup}
    {state, reply}
  end

  defp handle_language_update(data, chat_id, state) do
    [language_code, subscription_id_str] = String.split(data, ":")
    subscription_id = String.to_integer(subscription_id_str)

    case ChatSubscriptionManager.update_subscription_setting(subscription_id, :language, language_code) do
      :ok -> {state, %{chat_id: chat_id, text: "Language has been set to #{language_code}."}}
      {:error, reason} -> {state, %{chat_id: chat_id, text: "Failed to set language: #{reason}"}}
    end
  end

  defp extract_chats_with_titles(subscriptions) do
    subscriptions
    |> Enum.map(& &1.chat_id)
    |> Enum.uniq()
    |> Enum.map(&fetch_chat_title/1)
  end

  defp fetch_chat_title(chat_id) do
    case TelegramClientImpl.get_chat(chat_id) do
      {:ok, %{"title" => title}} -> {chat_id, title}
      {:error, _reason} -> {chat_id, "Chat #{chat_id}"}
    end
  end

  defp build_chat_buttons(chats) do
    chat_buttons = Enum.map(chats, fn {chat_id, title} -> [%{text: title, callback_data: "manage_chat:#{chat_id}"}] end)

    all_actions_buttons = [
      [%{text: "Pause All", callback_data: "pauseall"}],
      [%{text: "Restart All", callback_data: "restartall"}],
      [%{text: "Unsubscribe All", callback_data: "unsubscribeall"}]
    ]

    chat_buttons ++ all_actions_buttons
  end

  defp build_subscription_buttons(subscriptions) do
    Enum.map(subscriptions, fn subscription ->
      token_label = Utils.token_address_with_sym(subscription.token_address, subscription.chain_id)
      chain_label = BlockchainConfig.get_chain_label(subscription.chain_id)
      status = if subscription.paused, do: "Paused", else: "Active"
      display_label = "#{chain_label}, #{token_label}, #{status}"
      [%{text: display_label, callback_data: "manage_subscription:#{subscription.id}"}]
    end)
  end
end
