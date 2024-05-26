defmodule SwapListener.Telegram.RateLimitedTelegramClientImpl do
  @moduledoc false
  @behaviour SwapListener.Telegram.TelegramClient

  alias SwapListener.Telegram.RateLimiter

  require Logger

  @rate_limiter_pid :telegram_rate_limiter

  @doc """
  Schedules a message to be sent with rate limiting.
  """
  def send_message(chat_id, text, opts \\ []) do
    schedule(:message, chat_id, text, opts)
  end

  @doc """
  Schedules a photo to be sent with rate limiting.
  """
  def send_photo(chat_id, photo_url, caption \\ "", opts \\ []) do
    opts = Keyword.put_new(opts, :caption, caption)
    schedule(:photo, chat_id, photo_url, opts)
  end

  @doc """
  Schedules an animation to be sent with rate limiting.
  """
  def send_animation(chat_id, animation_url, caption \\ "", opts \\ []) do
    opts = Keyword.put_new(opts, :caption, caption)
    schedule(:animation, chat_id, animation_url, opts)
  end

  defp schedule(type, chat_id, content, opts) do
    RateLimiter.schedule_send(@rate_limiter_pid, type, chat_id, content, opts)
    :ok
  end
end
