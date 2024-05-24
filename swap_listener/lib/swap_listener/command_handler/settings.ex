defmodule SwapListener.CommandHandler.Settings do
  @moduledoc false

  alias SwapListener.ChatSubscriptionManager
  alias SwapListener.CommandHandler.Utils

  @telegram_client Application.compile_env(:swap_listener, :telegram_client, SwapListener.RateLimitedTelegramClientImpl)

  def handle(chat_id, args, state) do
    case args do
      [token_address, chain_id | rest] ->
        if Enum.empty?(rest) do
          message =
            "No settings provided. Use the format /settings token_address chain_id option:value to update settings. For example, /settings 0xTokenAddress 1 min_buy_amount:100."

          @telegram_client.send_message(chat_id, message)
          {state, nil}
        else
          parsed_chain_id = String.to_integer(chain_id)
          update_subscription_settings(chat_id, token_address, parsed_chain_id, rest)
          {state, nil}
        end

      _ ->
        @telegram_client.send_message(
          chat_id,
          "Please provide a token address and chain ID along with the settings to update. Here are your current subscriptions:"
        )

        list_subscriptions(chat_id)

        {state, nil}
    end
  end

  defp update_subscription_settings(chat_id, token_address, chain_id, args) do
    case parse_settings(args) do
      {:ok, settings} ->
        ChatSubscriptionManager.update_subscription_settings(chat_id, token_address, chain_id, settings)

      {:error, reason} ->
        @telegram_client.send_message(chat_id, "Failed to update settings: #{reason}")
    end
  end

  defp parse_settings(args) do
    if valid_settings_args?(args) do
      settings =
        Enum.reduce(args, %{}, fn arg, acc ->
          case String.split(arg, ":") do
            [key, value] -> Map.put(acc, String.to_atom(key), value)
            _ -> acc
          end
        end)

      {:ok, settings}
    else
      {:error, "Invalid settings format. Please provide settings in the format option:value."}
    end
  end

  defp valid_settings_args?(args) do
    allowed_keys = [
      # Link to buy token, e.g., on 1inch
      "buy_link",
      # Link to deposit funds
      "deposit_link",
      # Link to view the token chart
      "chart_link",
      # Official website of the token
      "website_url",
      # Minimum amount to show alerts for
      "min_buy_amount",
      # Step size for trade size
      "trade_size_step",
      # Image URL for alerts
      "alert_image_url",
      # Official website of the token
      "website_url",
      # Twitter link of the token
      "twitter_handle",
      # Discord link
      "discord_link",
      # Telegram link
      "telegram_link"
    ]

    Enum.all?(args, fn arg ->
      case String.split(arg, ":") do
        [key, _value] -> key in allowed_keys
        _ -> false
      end
    end)
  end

  defp list_subscriptions(chat_id) do
    case ChatSubscriptionManager.list_subscriptions(chat_id) do
      [] ->
        @telegram_client.send_message(chat_id, "You are not subscribed to any tokens.")

      subscriptions when is_list(subscriptions) ->
        message = Utils.format_subscription_list(subscriptions)
        @telegram_client.send_message(chat_id, message)

      _ ->
        @telegram_client.send_message(chat_id, "Failed to fetch subscriptions.")
    end
  end
end
