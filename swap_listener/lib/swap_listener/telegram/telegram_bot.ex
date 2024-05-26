defmodule SwapListener.Telegram.TelegramBot do
  @moduledoc false
  use Telegram.ChatBot

  alias SwapListener.Bot.ActionHandler
  alias SwapListener.Bot.AllowList
  alias SwapListener.Bot.CommandDispatcher
  alias SwapListener.Bot.Commands.Manage
  alias SwapListener.ChatSubscription.ChatSubscriptionManager
  alias SwapListener.Telegram.RateLimiter
  alias SwapListener.Telegram.TelegramClientImpl

  require Logger

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
      telegram_link: nil,
      updating: nil
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
      TelegramClientImpl.send_message(reply.chat_id, reply.text, reply)
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
      case state[:step] do
        %{updating: setting_key} -> CommandDispatcher.handle_step(%{updating: setting_key}, text, chat_id, user_id, state)
        _ -> {state, nil}
      end
    end
  end

  defp handle_message(
         %{"text" => text, "chat" => %{"id" => chat_id, "type" => type}, "from" => %{"username" => username}},
         state
       )
       when type != "private" do
    Logger.debug("Received message: #{text} from chat: #{chat_id} in #{type} chat")

    TelegramClientImpl.send_message(
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
      TelegramClientImpl.send_message(
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
        String.starts_with?(data, "pauseall") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "restartall") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "unsubscribeall") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "manage_chat:") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "manage_subscription:") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "pause_subscription:") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "restart_subscription:") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "unsubscribe_subscription:") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "change_settings:") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "update_") -> Manage.handle_callback_query(data, chat_id, nil, state)
        String.starts_with?(data, "set_language:") -> Manage.handle_callback_query(data, chat_id, nil, state)
        true -> handle_step_callback(data, state, chat_id, chat_id)
      end

    answer_callback_query(callback_query_id)
    {new_state, reply}
  end

  defp handle_step_callback(data, state, chat_id, user_id) do
    case state[:step] do
      %{updating: setting_key} ->
        CommandDispatcher.handle_step(%{updating: setting_key}, data, chat_id, user_id, state)

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
