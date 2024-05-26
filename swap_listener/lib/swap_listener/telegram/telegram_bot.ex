defmodule SwapListener.Telegram.TelegramBot do
  @moduledoc false
  use Telegram.ChatBot

  alias SwapListener.Bot.ActionHandler
  alias SwapListener.Bot.AllowList
  alias SwapListener.Bot.CommandDispatcher
  alias SwapListener.ChatSubscription.ChatSubscriptionManager
  alias SwapListener.Telegram.RateLimiter
  alias SwapListener.Telegram.TelegramClientImpl

  require Logger

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  @session_ttl 86_400_000

  @impl Telegram.ChatBot
  def init(_chat) do
    state = %{
      step: nil,
      chat_id: nil,
      token_address: nil,
      chain_id: nil,
      alert_image_url: nil,
      website_url: nil,
      twitter_handle: nil,
      discord_link: nil,
      telegram_link: nil
    }

    {:ok, state, @session_ttl}
  end

  @impl Telegram.ChatBot
  def handle_update(update, _context, state) do
    Logger.debug("Received update: #{inspect(update)}. State: #{inspect(state)}")

    {new_state, reply} =
      case update do
        %{"message" => message} ->
          handle_message(message, state)

        %{"edited_message" => message} ->
          handle_message(message, state)

        %{"callback_query" => callback_query} ->
          handle_callback_query(callback_query, state)

        _ ->
          Logger.info("Unhandled message type")
          {state, nil}
      end

    if reply do
      @telegram_client.send_message(reply.chat_id, reply.text, reply)
    end

    Logger.debug("New state: #{inspect(new_state)} with reply: #{inspect(reply)}")

    {:ok, new_state, @session_ttl}
  end

  defp handle_message(
         %{"text" => text, "chat" => %{"id" => chat_id, "type" => "private"}, "from" => %{"id" => user_id}},
         state
       ) do
    Logger.debug("Received private message: #{text} from chat: #{chat_id}")

    if String.starts_with?(text, "/") do
      [command | args] = String.split(text)
      CommandDispatcher.dispatch(command, chat_id, user_id, args, state)
    else
      if state[:step] do
        CommandDispatcher.handle_step(state[:step], text, chat_id, user_id, state)
      else
        Logger.debug("Ignoring non-command message")
        {state, nil}
      end
    end
  end

  defp handle_message(
         %{"text" => text, "chat" => %{"id" => chat_id, "type" => type}, "from" => %{"username" => username}},
         state
       )
       when type != "private" do
    Logger.debug("Received message: #{text} from chat: #{chat_id} in #{type} chat")

    @telegram_client.send_message(
      chat_id,
      "Hello #{username}! I only respond to commands in private chats. Please send me a direct message."
    )

    {state, nil}
  end

  defp handle_message(
         %{
           "new_chat_member" => %{"username" => _username, "is_bot" => true},
           "chat" => %{"id" => chat_id},
           "from" => %{"username" => from_username}
         },
         state
       ) do
    if AllowList.allowed?(from_username) do
      @telegram_client.send_message(
        chat_id,
        "Hello #{from_username}! Please select your language by typing /language followed by the language code. Available languages: en, fr, es, pt, de, it, nl, pl, ru, zh, ja, ko."
      )

      Logger.info("Sent hello message to #{from_username}")
    else
      Logger.warning("User #{from_username} is not allowed to add members")
      TelegramClientImpl.send_message(chat_id, "Sorry, I'm not allowed to be added by you.", [])
      TelegramClientImpl.leave_chat(chat_id)
    end

    {state, nil}
  end

  defp handle_message(
         %{"left_chat_member" => %{"username" => _username, "is_bot" => true}, "chat" => %{"id" => chat_id}},
         state
       ) do
    handle_bot_removed_from_chat(chat_id, state)
  end

  defp handle_message(
         %{
           "chat" => %{"id" => this_chat_id},
           "chat_shared" => %{"chat_id" => shared_chat_id},
           "from" => %{"id" => user_id}
         },
         state
       ) do
    Logger.info("Chat shared: #{shared_chat_id}")

    if state[:step] do
      CommandDispatcher.handle_step(state[:step], shared_chat_id, this_chat_id, user_id, state)
    else
      Logger.debug("Ignoring chat shared message")
      {state, nil}
    end
  end

  defp handle_message(message, state) do
    Logger.info("Unhandled message received: #{inspect(message)}")
    {state, nil}
  end

  defp handle_callback_query(
         %{"data" => data, "id" => callback_query_id, "message" => %{"chat" => %{"id" => chat_id}}},
         state
       ) do
    {new_state, reply} =
      cond do
        data == "pauseall" ->
          {state, ActionHandler.pause_all(chat_id)}

        data == "restartall" ->
          {state, ActionHandler.restart_all(chat_id)}

        data == "unsubscribeall" ->
          {state, ActionHandler.unsubscribe_all(chat_id)}

        String.starts_with?(data, "manage_subscription:") ->
          subscription_id = data |> String.split(":") |> List.last() |> String.to_integer()
          handle_subscription_management(subscription_id, state, chat_id)

        String.starts_with?(data, "update_") ->
          handle_update_query(data, state, chat_id)

        true ->
          handle_step_callback(data, state, chat_id, chat_id)
      end

    answer_callback_query(callback_query_id)
    {new_state, reply}
  end

  defp handle_subscription_management(subscription_id, state, chat_id) do
    # Fetch the current subscription
    case ChatSubscriptionManager.get_subscription_by_id(subscription_id) do
      nil ->
        reply = %{chat_id: chat_id, text: "Subscription not found."}
        {state, reply}

      subscription ->
        # Format the settings into inline keyboard buttons
        settings =
          subscription
          |> Map.from_struct()
          |> Enum.filter(fn {key, _} ->
            key in ~w(min_buy_amount trade_size_emoji trade_size_step alert_image_url website_url twitter_handle discord_link telegram_link)a
          end)

        inline_keyboard =
          for {key, value} <- settings do
            [%{"text" => "#{key}: #{value}", "callback_data" => "update_#{key}:#{subscription_id}"}]
          end

        # Send a message with the inline keyboard
        reply = %{
          chat_id: chat_id,
          text: "Managing subscription: #{subscription_id}. What setting would you like to update?",
          reply_markup: %{"inline_keyboard" => inline_keyboard}
        }

        {Map.put(state, :current_subscription, subscription_id), reply}
    end
  end

  defp handle_update_query(data, state, chat_id) do
    [setting, subscription_id_str] = String.split(data, ":")
    subscription_id = String.to_integer(subscription_id_str)
    setting_key = setting |> String.replace_prefix("update_", "") |> String.to_atom()

    new_state =
      state
      |> Map.put(:step, {:updating, setting_key})
      |> Map.put(:current_subscription, subscription_id)

    reply = %{chat_id: chat_id, text: "Please enter the new value for `#{setting_key}`:"}
    {new_state, reply}
  end

  defp handle_step_callback(data, state, chat_id, user_id) do
    case state[:step] do
      :chain_id ->
        CommandDispatcher.handle_step(:chain_id, data, chat_id, user_id, state)

      _ ->
        Logger.info("Unhandled callback query step")
        {state, nil}
    end
  end

  defp handle_bot_removed_from_chat(chat_id, state) do
    Logger.info("Bot removed from chat: #{chat_id}, archiving subscriptions")
    ChatSubscriptionManager.archive_subscriptions(chat_id)
    RateLimiter.clear_messages_for_chat(chat_id)
    {state, nil}
  end

  defp answer_callback_query(callback_query_id) do
    TelegramClientImpl.answer_callback_query(callback_query_id)
  end
end
