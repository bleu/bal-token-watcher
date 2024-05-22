defmodule SwapListener.NotificationServiceTest do
  use SwapListener.DataCase, async: false

  import Mox

  alias SwapListener.ChatSubscription
  alias SwapListener.NotificationService
  alias SwapListener.Repo

  setup :verify_on_exit!

  describe "handle_notification/1" do
    test "sends notification message" do
      # Insert a subscription that matches the notification criteria
      chat_id = 123
      token_address = "0xtokenout123456"
      chain_id = 1

      Repo.insert!(%ChatSubscription{
        chat_id: chat_id,
        token_address: token_address,
        chain_id: chain_id,
        min_buy_amount: Decimal.new("0.1"),
        trade_size_emoji: "💰",
        trade_size_step: Decimal.new("0.1"),
        alert_image_url: "http://example.com/alert.png",
        website_url: "http://example.com",
        twitter_handle: "@example",
        discord_link: "http://example.com/discord",
        telegram_link: "http://example.com/telegram",
        paused: false
      })

      expect(SwapListener.TelegramClientMock, :send_photo, fn ^chat_id, "http://example.com/alert.png", _message ->
        :ok
      end)

      # Define the notification
      notification = %{
        "block" => 123_456,
        "caller" => "0x1234567890abcdef",
        "chain_id" => chain_id,
        "id" => "0xabcdef1234567890",
        "inserted_at" => nil,
        "pool_id" => "0xpoolid123456",
        "timestamp" => DateTime.to_unix(DateTime.utc_now()),
        "token_amount_in" => "100.0",
        "token_amount_out" => "50.0",
        "token_in" => "0xtokenin123456",
        "token_in_sym" => "ETH",
        "token_out" => token_address,
        "token_out_sym" => "DAI",
        "tx" => "0xtx1234567890abcdef",
        "updated_at" => nil,
        "user_address" => "0xuseraddress123456",
        "value_usd" => "5000.0",
        "dexscreener_url" => "https://example.com/dex-screener"
      }

      # Call the handle_notification function
      NotificationService.handle_notification(notification)
    end
  end
end
