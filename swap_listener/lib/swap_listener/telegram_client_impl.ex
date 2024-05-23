defmodule SwapListener.TelegramClientImpl do
  @moduledoc false
  @behaviour SwapListener.TelegramClient

  alias SwapListener.ChatSubscriptionManager

  require Logger

  @doc """
  Sends a message to a specific chat_id.
  """
  def send_message(chat_id, text) do
    token = Application.fetch_env!(:telegram, :token)
    Logger.debug("Attempting to send message to #{chat_id}: #{text}")

    case Telegram.Api.request(token, "sendMessage",
           chat_id: chat_id,
           text: text,
           parse_mode: "Markdown"
         ) do
      {:ok, response} ->
        Logger.debug("Message sent successfully to #{chat_id}. Response: #{inspect(response)}")
        :ok

      {:error, %{"description" => "Forbidden: bot was kicked from the group chat"}} ->
        Logger.error("Failed to send message to #{chat_id}: bot was kicked from the group chat")
        ChatSubscriptionManager.archive_subscriptions(chat_id)
        {:error, :bot_kicked}

      {:error, error} ->
        Logger.error("Failed to send message to #{chat_id}: #{inspect(error)}")
        {:error, error}
    end
  rescue
    error ->
      Logger.error("Unexpected error while sending message to #{chat_id}: #{inspect(error)}")
      {:error, error}
  end

  @doc """
  Sends a photo to a specific chat_id with an optional caption.
  """
  def send_photo(chat_id, photo_url, caption \\ "") do
    token = Application.fetch_env!(:telegram, :token)
    Logger.debug("Attempting to send photo to #{chat_id}: #{photo_url} with caption: #{caption}")

    case Telegram.Api.request(token, "sendPhoto",
           chat_id: chat_id,
           photo: photo_url,
           caption: caption,
           parse_mode: "Markdown"
         ) do
      {:ok, response} ->
        Logger.debug("Photo sent successfully to #{chat_id}. Response: #{inspect(response)}")
        :ok

      {:error, %{"description" => "Forbidden: bot was kicked from the group chat"}} ->
        Logger.error("Failed to send photo to #{chat_id}: bot was kicked from the group chat")
        ChatSubscriptionManager.archive_subscriptions(chat_id)
        {:error, :bot_kicked}

      {:error, error} ->
        Logger.error("Failed to send photo to #{chat_id}: #{inspect(error)}")
        {:error, error}
    end
  rescue
    error ->
      Logger.error("Unexpected error while sending photo to #{chat_id}: #{inspect(error)}")
      {:error, error}
  end

  def set_my_commands(commands) do
    token = Application.fetch_env!(:telegram, :token)
    Logger.debug("Setting commands: #{inspect(commands)}")

    case Telegram.Api.request(token, "setMyCommands",
           commands: commands,
           scope: %{type: "all_private_chats"},
           language_code: "en"
         ) do
      {:ok, response} ->
        Logger.debug("Commands set successfully. Response: #{inspect(response)}")
        :ok

      {:error, error} ->
        Logger.error("Failed to set commands: #{inspect(error)}")
        {:error, error}
    end
  end

  def leave_chat(chat_id) do
    token = Application.fetch_env!(:telegram, :token)
    Logger.debug("Leaving chat: #{chat_id}")

    case Telegram.Api.request(token, "leaveChat", chat_id: chat_id) do
      {:ok, response} ->
        Logger.debug("Left chat successfully: #{chat_id}. Response: #{inspect(response)}")
        :ok

      {:error, error} ->
        Logger.error("Failed to leave chat: #{chat_id}. Error: #{inspect(error)}")
        {:error, error}
    end
  end
end
