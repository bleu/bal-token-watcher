defmodule SwapListener.TelegramClient do
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

    # log any errors that occur
  rescue
    error -> Logger.error("Failed to send message: #{inspect(error)}")
  end
end
