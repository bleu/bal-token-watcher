defmodule SwapListener.Telegram.TelegramClientImpl do
  @moduledoc false
  @behaviour SwapListener.Telegram.TelegramClient

  alias SwapListener.ChatSubscription.ChatSubscriptionManager
  alias SwapListener.Telegram.RateLimiter

  require Logger

  @token Application.compile_env(:telegram, :token)

  @doc """
  Sends a message to a specific chat_id.
  """
  def send_message(chat_id, text, opts \\ []) do
    message_opts =
      opts
      |> Enum.into([])
      |> Keyword.merge(text: text, chat_id: chat_id, parse_mode: "Markdown")

    send_telegram_request("sendMessage", message_opts)
  end

  @doc """
  Sends a photo to a specific chat_id with an optional caption.
  """
  def send_photo(chat_id, photo_url, caption \\ "", opts \\ []) do
    photo_opts =
      opts
      |> Enum.into([])
      |> Keyword.merge(chat_id: chat_id, photo: photo_url, caption: caption, parse_mode: "Markdown")

    send_telegram_request("sendPhoto", photo_opts)
  end

  @doc """
  Sends an animation (GIF) to a specific chat_id with an optional caption.
  """
  def send_animation(chat_id, animation_url, caption \\ "", opts \\ []) do
    animation_opts =
      opts
      |> Enum.into([])
      |> Keyword.merge(chat_id: chat_id, animation: animation_url, caption: caption, parse_mode: "Markdown")

    send_telegram_request("sendAnimation", animation_opts)
  end

  defp send_telegram_request(method, params) do
    Logger.debug("Sending request to Telegram API method #{method} with params: #{inspect(params)}")

    case Telegram.Api.request(@token, method, params) do
      {:ok, response} ->
        Logger.debug("#{method} sent successfully. Response: #{inspect(response)}")
        {:ok, response}

      {:error, %{"description" => reason} = error} ->
        handle_error_response(reason, params[:chat_id], method, error)

      {:error, error} ->
        Logger.error("Failed to send #{method}: #{inspect(error)}")
        {:error, error}
    end
  rescue
    exception ->
      Logger.error("Unexpected error while sending #{method}: #{inspect(exception)}")
      {:error, exception}
  end

  defp handle_error_response("Forbidden: bot was kicked from the group chat", chat_id, _method, _error) do
    handle_bot_kicked(chat_id, "Bot was kicked from the group chat")
    {:error, :bot_kicked}
  end

  defp handle_error_response("chat not found", chat_id, _method, _error) do
    handle_bot_kicked(chat_id, "Chat not found")
    {:error, :chat_not_found}
  end

  defp handle_error_response(reason, _chat_id, method, error) do
    Logger.error("Failed to send #{method}: #{inspect(error)}")
    {:error, reason}
  end

  defp handle_bot_kicked(chat_id, reason) do
    Logger.error("Bot was kicked from the group chat #{chat_id}: #{reason}")
    ChatSubscriptionManager.archive_subscriptions(chat_id)
    RateLimiter.clear_messages_for_chat(chat_id)
  end

  @doc """
  Sets commands for the bot.
  """
  def set_my_commands(commands) do
    command_params = [commands: commands, scope: %{type: "all_private_chats"}, language_code: "en"]
    send_telegram_request("setMyCommands", command_params)
  end

  @doc """
  Leaves a chat.
  """
  def leave_chat(chat_id) do
    Logger.debug("Attempting to leave chat: #{chat_id}")
    send_telegram_request("leaveChat", chat_id: chat_id)
  end

  @doc """
  Fetches chat member information for a given chat_id and user_id.
  """
  def get_chat_member(chat_id, user_id) do
    member_params = [chat_id: chat_id, user_id: user_id]
    send_telegram_request("getChatMember", member_params)
  end

  @doc """
  Answers a callback query.
  """
  def answer_callback_query(callback_query_id) do
    send_telegram_request("answerCallbackQuery", callback_query_id: callback_query_id)
  end

  @doc """
  Fetches chat information for a given chat_id.
  """
  def get_chat(chat_id) do
    send_telegram_request("getChat", chat_id: chat_id)
  end
end
