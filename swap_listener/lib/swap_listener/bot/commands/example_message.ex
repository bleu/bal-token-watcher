defmodule SwapListener.Bot.Commands.ExampleMessage do
  @moduledoc false
  alias SwapListener.Bot.NotificationService

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  def handle(chat_id, user_id, args, state) do
    language = List.first(args) || "en"

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
      trade_size_step: Decimal.new("1.0"),
      alert_image_url: "https://example.com/image.gif",
      website_url: "https://example.com",
      twitter_handle: "https://example.com",
      discord_link: "https://discord.gg/example",
      telegram_link: "https://t.me/example",
      paused: false,
      archived_at: nil,
      creator_id: user_id,
      language: language
    }

    message = NotificationService.format_message(example_notification, subscription)
    @telegram_client.send_message(chat_id, message)

    settings_message = format_subscription_settings(subscription)
    @telegram_client.send_message(chat_id, settings_message)

    {state, nil}
  end

  defp format_subscription_settings(subscription) do
    """
    *Example Subscription Settings:*
    - *Chat Title:* #{subscription.chat_title}
    - *Token Address:* #{subscription.token_address}
    - *Chain ID:* #{subscription.chain_id}
    - *Minimum Buy Amount:* #{Decimal.to_string(subscription.min_buy_amount)}
    - *Trade Size Emoji:* #{subscription.trade_size_emoji}
    - *Trade Size Step:* #{Decimal.to_string(subscription.trade_size_step)}
    - *Alert Image URL:* #{subscription.alert_image_url}
    - *Website URL:* #{subscription.website_url}
    - *Twitter Handle:* #{subscription.twitter_handle}
    - *Discord Link:* #{subscription.discord_link}
    - *Telegram Link:* #{subscription.telegram_link}
    - *Paused:* #{subscription.paused}
    - *Language:* #{subscription.language}
    """
  end
end
