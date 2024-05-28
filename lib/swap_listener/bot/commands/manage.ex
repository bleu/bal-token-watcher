defmodule SwapListener.Bot.Commands.Manage do
  @moduledoc false
  alias SwapListener.Bot.Commands.Manage.All
  alias SwapListener.Bot.Commands.Manage.Chat
  alias SwapListener.Bot.Commands.Manage.Chat.Subscription
  alias SwapListener.Bot.Commands.Manage.Chat.Subscription.Settings
  alias SwapListener.Bot.Commands.Manage.Chat.Subscription.Settings.Language
  alias SwapListener.Bot.Commands.Manage.Chat.Subscription.Settings.Links
  alias SwapListener.Bot.Commands.Utils
  alias SwapListener.ChatSubscription.ChatSubscriptionManager
  alias SwapListener.Telegram.TelegramClientImpl

  require Logger

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

  def handle_manage_updates(setting, text, chat_id, _user_id, state) do
    Logger.debug("Updating setting: #{inspect(setting)} with text: #{inspect(text)}")

    case setting do
      :min_buy_amount ->
        Utils.set_setting(:min_buy_amount, Decimal.new(text), state[:current_subscription], chat_id, state)

      :trade_size_emoji ->
        Utils.set_setting(:trade_size_emoji, text, state[:current_subscription], chat_id, state)

      :trade_size_step ->
        Utils.set_setting(:trade_size_step, Decimal.new(text), state[:current_subscription], chat_id, state)

      :alert_image_url ->
        Utils.set_setting(:alert_image_url, text, state[:current_subscription], chat_id, state)

      {:edit_label, link_id} ->
        case ChatSubscriptionManager.update_link_label(state[:current_subscription], link_id, text) do
          :ok -> {state, %{chat_id: chat_id, text: "Link label updated."}}
          {:error, _} -> {state, %{chat_id: chat_id, text: "Failed to update link label."}}
        end

      :add_link ->
        case ChatSubscriptionManager.add_link(state[:current_subscription], text) do
          :ok -> {state, %{chat_id: chat_id, text: "Link added."}}
          {:error, _} -> {state, %{chat_id: chat_id, text: "Failed to add link."}}
        end

      :reorder_links ->
        indexes = String.split(text, ",", trim: true)

        case ChatSubscriptionManager.reorder_links(state[:current_subscription], indexes) do
          :ok -> {state, %{chat_id: chat_id, text: "Links have been reordered."}}
          {:error, message} -> {state, %{chat_id: chat_id, text: message}}
        end

      _ ->
        {state, %{chat_id: chat_id, text: "Unknown setting."}}
    end
  end

  def handle_callback_query(data, chat_id, _user_id, state) do
    case String.split(data, ":") do
      ["pauseall"] ->
        All.pause_all(chat_id, state)

      ["restartall"] ->
        All.restart_all(chat_id, state)

      ["unsubscribeall"] ->
        All.unsubscribe_all(chat_id, state)

      ["manage_chat", managed_chat_str] ->
        Chat.prompt(managed_chat_str, chat_id, state)

      ["manage_subscription", subscription_id] ->
        Subscription.prompt(subscription_id, chat_id, state)

      ["pause_subscription", subscription_id] ->
        Subscription.pause(subscription_id, chat_id, state)

      ["restart_subscription", subscription_id] ->
        Subscription.restart(subscription_id, chat_id, state)

      ["unsubscribe_subscription", subscription_id] ->
        Subscription.unsubscribe(subscription_id, chat_id, state)

      ["change_settings", subscription_id] ->
        Settings.prompt(subscription_id, chat_id, state)

      ["manage_links", subscription_id] ->
        Links.prompt(subscription_id, chat_id, state)

      ["edit_link_action", action, link_type, subscription_id] ->
        Links.edit_link_action(action, link_type, subscription_id, chat_id, state)

      ["edit_link_action", action, subscription_id] ->
        Links.edit_link_action(action, subscription_id, chat_id, state)

      ["update_min_buy_amount", subscription_id] ->
        update_min_buy_amount(subscription_id, chat_id, state)

      ["update_trade_size_emoji", subscription_id] ->
        update_trade_size_emoji(subscription_id, chat_id, state)

      ["update_trade_size_step", subscription_id] ->
        update_trade_size_step(subscription_id, chat_id, state)

      ["update_alert_image_url", subscription_id] ->
        update_alert_image_url(subscription_id, chat_id, state)

      ["update_language", subscription_id] ->
        Language.prompt(subscription_id, chat_id, state)

      ["set_language", language_code, subscription_id] ->
        alias SwapListener.Bot.Commands.Utils

        Utils.set_setting(:language, language_code, subscription_id, chat_id, state)

      _ ->
        {state, %{chat_id: chat_id, text: "Unknown action."}}
    end
  end

  defp update_min_buy_amount(subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, :min_buy_amount, subscription_id, "Please enter the new minimum buy amount:")
  end

  defp update_trade_size_emoji(subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, :trade_size_emoji, subscription_id, "Please enter the new trade size emoji:")
  end

  defp update_trade_size_step(subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, :trade_size_step, subscription_id, "Please enter the new trade size step:")
  end

  defp update_alert_image_url(subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, :alert_image_url, subscription_id, "Please enter the new alert image URL:")
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
      {:ok, %{"username" => username}} -> {chat_id, "Chat with #{username}"}
      {:error, _reason} -> {chat_id, "Chat #{chat_id}"}
      _ -> {chat_id, "Chat #{chat_id}"}
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
end
