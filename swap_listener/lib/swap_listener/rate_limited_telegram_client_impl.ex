defmodule SwapListener.RateLimitedTelegramClientImpl do
  @moduledoc false
  @behaviour SwapListener.TelegramClient

  alias SwapListener.RateLimiter

  require Logger

  @doc """
  Schedules a message to be sent with rate limiting.
  """
  def send_message(chat_id, text) do
    Logger.debug("Scheduling message to be sent to chat_id: #{chat_id}, text: #{text}")
    RateLimiter.schedule_send_message(chat_id, text)
    :ok
  end

  @doc """
  Schedules a photo to be sent with rate limiting.
  """
  def send_photo(chat_id, photo_url, caption \\ "") do
    RateLimiter.schedule_send_photo(chat_id, photo_url, caption)
    :ok
  end

  @doc """
  Schedules an animation to be sent with rate limiting.
  """
  def send_animation(chat_id, animation_url, caption \\ "") do
    RateLimiter.schedule_send_animation(chat_id, animation_url, caption)
    :ok
  end
end
