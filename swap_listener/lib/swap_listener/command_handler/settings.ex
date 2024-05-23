defmodule SwapListener.CommandHandler.Settings do
  @moduledoc false
  alias SwapListener.BlockchainConfig
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

        @telegram_client.send_message(
          chat_id,
          "Settings updated successfully for #{token_address} on chain #{BlockchainConfig.get_chain_label(chain_id)}. New settings: #{inspect(settings)}"
        )

      {:error, reason} ->
        @telegram_client.send_message(chat_id, "Failed to update settings: #{reason}")
    end
  end

  defp parse_settings(args) do
    if valid_settings_args?(args) do
      settings =
        Enum.map(args, fn arg ->
          case String.split(arg, ":") do
            [key, value] -> {:ok, {String.to_atom(key), value}}
            _ -> {:error, "Invalid format for #{arg}"}
          end
        end)

      if Enum.any?(settings, &match?({:error, _}, &1)) do
        {:error, Enum.filter(settings, &match?({:error, _}, &1))}
      else
        {:ok, Enum.map(settings, fn {:ok, setting} -> setting end)}
      end
    else
      {:error, "Invalid settings format. Please provide settings in the format option:value."}
    end
  end

  defp valid_settings_args?(args) do
    allowed_keys = ["min_buy_amount", "trade_size_step", "alert_image_url"]

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
