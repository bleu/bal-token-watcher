# test/swap_listener/telegram_client_test.exs
defmodule SwapListener.TelegramClientTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  alias SwapListener.TelegramClient

  test "send_message logs the message" do
    chat_id = 123
    message = "Test message"

    assert capture_log(fn -> TelegramClient.send_message(chat_id, message) end) =~
             "Sending message to 123: Test message"
  end
end
