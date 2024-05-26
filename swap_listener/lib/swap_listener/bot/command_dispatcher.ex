defmodule SwapListener.Bot.CommandDispatcher do
  @moduledoc false

  alias SwapListener.Bot.Commands.AddToken
  alias SwapListener.Bot.Commands.ExampleMessage
  alias SwapListener.Bot.Commands.Help
  alias SwapListener.Bot.Commands.Manage
  alias SwapListener.Bot.Commands.Start
  alias SwapListener.Bot.Commands.Subscriptions

  @handlers %{
    "/addtoken" => {AddToken, :handle},
    "/help" => {Help, :handle},
    "/start" => {Start, :handle},
    "/manage" => {Manage, :handle},
    "/subscriptions" => {Subscriptions, :handle},
    "/example" => {ExampleMessage, :handle}
  }

  def dispatch(command, chat_id, user_id, args, state) do
    case Map.get(@handlers, command) do
      {module, function} -> apply(module, function, [chat_id, user_id, args, state])
      _ -> {state, %{chat_id: chat_id, text: "Unknown command. Please type /help for a list of available commands."}}
    end
  end

  def handle_step(step, text, chat_id, user_id, state) do
    case step do
      :chat_selection -> AddToken.handle_step(:chat_selection, text, chat_id, user_id, state)
      :chain_id -> AddToken.handle_step(:chain_id, text, chat_id, user_id, state)
      :token_address -> AddToken.handle_step(:token_address, text, chat_id, user_id, state)
      :alert_image_url -> AddToken.handle_step(:alert_image_url, text, chat_id, user_id, state)
      :website_url -> AddToken.handle_step(:website_url, text, chat_id, user_id, state)
      :twitter_handle -> AddToken.handle_step(:twitter_handle, text, chat_id, user_id, state)
      :discord_link -> AddToken.handle_step(:discord_link, text, chat_id, user_id, state)
      :telegram_link -> AddToken.handle_step(:telegram_link, text, chat_id, user_id, state)
      :min_buy_amount -> AddToken.handle_step(:min_buy_amount, text, chat_id, user_id, state)
      :trade_size_emoji -> AddToken.handle_step(:trade_size_emoji, text, chat_id, user_id, state)
      :trade_size_step -> AddToken.handle_step(:trade_size_step, text, chat_id, user_id, state)
      {:updating, setting} -> handle_update_step(setting, text, chat_id, user_id, state)
      _ -> {state, %{chat_id: chat_id, text: "Unknown step."}}
    end
  end

  defp handle_update_step(setting, text, chat_id, _user_id, state) do
    case setting do
      :min_buy_amount -> update_subscription_setting(state, chat_id, :min_buy_amount, Decimal.new(text))
      :trade_size_emoji -> update_subscription_setting(state, chat_id, :trade_size_emoji, text)
      :trade_size_step -> update_subscription_setting(state, chat_id, :trade_size_step, Decimal.new(text))
      :alert_image_url -> update_subscription_setting(state, chat_id, :alert_image_url, text)
      :website_url -> update_subscription_setting(state, chat_id, :website_url, text)
      :twitter_handle -> update_subscription_setting(state, chat_id, :twitter_handle, text)
      :discord_link -> update_subscription_setting(state, chat_id, :discord_link, text)
      :telegram_link -> update_subscription_setting(state, chat_id, :telegram_link, text)
      :language -> update_language_setting(state, chat_id, text)
      _ -> {state, %{chat_id: chat_id, text: "Unknown setting."}}
    end
  end

  defp update_subscription_setting(state, chat_id, setting_key, setting_value) do
    subscription_id = state[:current_subscription]

    case SwapListener.ChatSubscription.ChatSubscriptionManager.update_subscription_setting(
           subscription_id,
           setting_key,
           setting_value
         ) do
      :ok ->
        new_state = Map.put(state, :step, nil)
        reply = %{chat_id: chat_id, text: "Successfully updated `#{setting_key}`."}
        {new_state, reply}

      :error ->
        new_state = Map.put(state, :step, nil)
        reply = %{chat_id: chat_id, text: "Failed to update `#{setting_key}`."}
        {new_state, reply}
    end
  end

  defp update_language_setting(state, chat_id, language) do
    subscription_id = state[:current_subscription]

    case SwapListener.ChatSubscription.ChatSubscriptionManager.update_subscription_setting(
           subscription_id,
           :language,
           language
         ) do
      :ok ->
        new_state = Map.put(state, :step, nil)
        reply = %{chat_id: chat_id, text: "Language set to #{language}."}
        {new_state, reply}

      :error ->
        new_state = Map.put(state, :step, nil)
        reply = %{chat_id: chat_id, text: "Failed to update language."}
        {new_state, reply}
    end
  end
end
