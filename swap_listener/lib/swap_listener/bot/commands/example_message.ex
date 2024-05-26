defmodule SwapListener.Bot.Commands.ExampleMessage do
  @moduledoc false
  alias SwapListener.Bot.NotificationService

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  def handle(chat_id, _command, _user_id, _, state) do
    example_notification = %{
      token_in: "0xExampleTokenIn",
      token_out: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
      token_in_sym: "ETH",
      token_out_sym: "EXMPL",
      token_amount_in: "1.0",
      token_amount_out: "100.0",
      value_usd: "2000.0",
      chain_id: 1,
      tx: "0xExampleTransactionHash",
      tx_link: "https://example.com/tx/0xExampleTransactionHash",
      buy_link: "https://example.com/buy/0xExampleTokenIn/0xExampleTokenOut",
      dexscreener_url: "https://example.com/dex/0xExampleTokenIn/0xExampleTokenOut",
      deposit_link: "https://example.com/deposit/0xExamplePool"
    }

    subscription = %{
      chat_id: chat_id,
      chat_title: "Example Chat",
      token_address: "0xExampleTokenIn",
      chain_id: 1,
      min_buy_amount: Decimal.new("1.0"),
      trade_size_emoji: "🚀",
      trade_size_step: Decimal.new("0.1"),
      alert_image_url: "https://example.com/image.gif",
      website_url: "https://example.com",
      twitter_handle: "example",
      discord_link: "https://discord.gg/example",
      telegram_link: "https://t.me/example",
      paused: false,
      archived_at: nil,
      creator_id: 1
    }

    message = NotificationService.format_message(example_notification, subscription)
    @telegram_client.send_message(chat_id, message)

    {state, nil}
  end
end
