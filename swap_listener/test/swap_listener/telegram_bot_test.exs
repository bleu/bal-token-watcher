# test/swap_listener/telegram_bot_test.exs
defmodule SwapListener.TelegramBotTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias SwapListener.TelegramBot

  test "handle_update processes message update" do
    update = %{"message" => %{"text" => "/start", "chat" => %{"id" => 123}}}
    assert capture_log(fn -> TelegramBot.handle_update(update, nil) end) =~ "Received update"
  end
end
