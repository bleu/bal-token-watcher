defmodule SwapListener.Bot.Commands.ExampleMessage do
  @moduledoc false
  alias SwapListener.Bot.Commands.Utils
  alias SwapListener.Bot.NotificationService

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  def handle(chat_id, user_id, args, state) do
    language = List.first(args) || "en"

    example_notification = %{
      token_in: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
      token_out: "0xExampleTokenOut",
      token_in_sym: "ETH",
      token_out_sym: "EXMPL",
      token_amount_in: "1.0",
      token_amount_out: "100.0",
      value_usd: "2000.0",
      chain_id: 1,
      tx: "0xExampleTransactionHash",
      tx_link: "https://example.com/tx/0xExampleTransactionHash",
      buy_link: "https://example.com/buy/0xExampleTokenOut/0xExampleTokenOut",
      dexscreener_url: "https://example.com/dex/0xExampleTokenOut/0xExampleTokenOut",
      deposit_link: "https://example.com/deposit/0xExamplePool"
    }

    subscription = %{
      chat_id: chat_id,
      chat_title: "Example Chat",
      token_address: "0xExampleTokenOut",
      chain_id: 1,
      min_buy_amount: Decimal.new("10.0"),
      trade_size_emoji: "🚀",
      trade_size_step: Decimal.new("10.0"),
      alert_image_url:
        "https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExdnlpMTU2b3B5Nmlhajl2Y2Z3dnQwdG5zZzZpNHpzamlsa29taGxrZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3orieS4jfHJaKwkeli/giphy.gif",
      website_url: "https://example.com",
      twitter_handle: "https://example.com",
      discord_link: "https://discord.gg/example",
      telegram_link: "https://t.me/example",
      paused: false,
      archived_at: nil,
      links: [
        %{
          "id" => "tx",
          "label" => "TX",
          "default" => true,
          "status" => "enabled"
        },
        %{
          "id" => "buy",
          "label" => "Buy",
          "default" => true,
          "status" => "enabled"
        },
        %{
          "id" => "deposit",
          "label" => "Deposit",
          "default" => true,
          "status" => "enabled"
        },
        %{
          "id" => "chart",
          "label" => "Chart",
          "default" => true,
          "status" => "enabled"
        }
      ],
      creator_id: user_id,
      language: language
    }

    NotificationService.send_message(subscription, example_notification)

    settings_message = format_subscription_settings(subscription)
    @telegram_client.send_message(chat_id, settings_message)

    {state, nil}
  end

  defp format_subscription_settings(subscription) do
    """
    *Example Subscription Settings:*
    #{Utils.format_subscription_settings(subscription)}
    """
  end
end
