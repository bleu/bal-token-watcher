defmodule SwapListener.TelegramClient do
  @moduledoc false
  require Logger

  @doc """
  Sends a message to a specific chat_id.
  """
  def send_message(chat_id, text) do
    token = Application.get_env(:swap_listener, :telegram_token)
    Logger.debug("Sending message to #{chat_id}: #{text}")

    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      text: text,
      parse_mode: "Markdown"
    )
  rescue
    error -> Logger.error("Failed to send message: #{inspect(error)}")
  end

  @doc """
  Sends a photo to a specific chat_id with an optional caption.
  """
  def send_photo(chat_id, photo_url, caption \\ "") do
    token = Application.get_env(:swap_listener, :telegram_token)
    Logger.debug("Sending photo to #{chat_id}: #{photo_url} with caption: #{caption}")

    Telegram.Api.request(token, "sendPhoto",
      chat_id: chat_id,
      photo: photo_url,
      caption: caption,
      parse_mode: "Markdown"
    )
  rescue
    error -> Logger.error("Failed to send photo: #{inspect(error)}")
  end
end
