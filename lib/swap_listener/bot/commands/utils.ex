defmodule SwapListener.Bot.Commands.Utils do
  @moduledoc false
  import Ecto.Query, only: [from: 2]

  alias SwapListener.Balancer.BalancerSwap
  alias SwapListener.ChatSubscription.ChatSubscriptionManager
  alias SwapListener.Common.BlockchainConfig
  alias SwapListener.Infra.Repo

  def set_setting(setting, value, subscription_id, chat_id, state) do
    case ChatSubscriptionManager.update_subscription_setting(subscription_id, setting, value) do
      :ok -> {state, %{chat_id: chat_id, text: "Setting #{setting} updated to #{value}."}}
      {:error, _reason} -> {state, %{chat_id: chat_id, text: "Failed to update setting."}}
    end
  end

  def set_step(state, chat_id, step, subscription_id, text) do
    new_state = Map.put(state, :step, %{updating: step})
    new_state = Map.put(new_state, :current_subscription, subscription_id)
    reply = %{chat_id: chat_id, text: text}
    {new_state, reply}
  end

  def format_subscription_table(subscriptions) do
    headers = ["Chat ID", "Chain", "Token (Symbol)", "Status"]

    column_widths = calculate_column_widths(headers, subscriptions)

    header = format_row(headers, column_widths)
    separator = format_separator(column_widths)

    rows =
      Enum.map_join(subscriptions, "\n", fn subscription ->
        format_subscription(subscription, column_widths)
      end)

    """
    ```
    #{header}
    #{separator}
    #{rows}
    ```
    """
  end

  def format_subscription_list(subscriptions) do
    Enum.map_join(subscriptions, "\n", fn subscription ->
      """
      - Chat ID: #{subscription.chat_id}
        Chain: #{BlockchainConfig.get_chain_label(subscription.chain_id)}
        Token: #{subscription.token_address} (#{get_token_sym(subscription.token_address, subscription.chain_id)})
        Status: #{if subscription.paused, do: "Paused", else: "Active"}
      """
    end)
  end

  def format_subscription_settings(subscription) do
    rows = [
      %{"Chat Title" => subscription.chat_title},
      %{"Token Address" => subscription.token_address},
      %{"Chain ID" => BlockchainConfig.get_chain_label(subscription.chain_id)},
      %{"Minimum Buy Amount" => subscription.min_buy_amount},
      %{"Trade Size Emoji" => subscription.trade_size_emoji},
      %{"Trade Size Step" => subscription.trade_size_step},
      %{"Alert Image URL" => subscription.alert_image_url},
      %{"Paused" => subscription.paused},
      %{"Language" => subscription.language},
      %{"Links" => subscription.links}
    ]

    rows
    |> Enum.map_join("\n", fn row ->
      label = row |> Map.keys() |> Enum.at(0)
      value = row |> Map.values() |> Enum.at(0)

      case value do
        links when is_list(links) ->
          """
          - *#{label}:*

          #{links |> Enum.map_join("\n", &format_link/1) |> String.trim_trailing()}
          """

        _ ->
          "- *#{label}:* #{value}"
      end
    end)
    |> String.trim_trailing()
  end

  defp format_link(link) do
    case link do
      %{
        "label" => label,
        "default" => default,
        "status" => status
      } ->
        "- *#{label}* (#{if default, do: "Default", else: "Not Default"}) (#{status})"

      %{
        "label" => label,
        "status" => status,
        "url" => url
      } ->
        """
        - *#{label}* (#{status})
            URL: #{url}
        """
    end
  end

  defp calculate_column_widths(headers, subscriptions) do
    initial_widths = Enum.map(headers, &String.length/1)

    Enum.reduce(subscriptions, initial_widths, fn subscription, acc ->
      [
        max(subscription.chat_id |> Integer.to_string() |> String.length(), Enum.at(acc, 0)),
        max(String.length(BlockchainConfig.get_chain_label(subscription.chain_id)), Enum.at(acc, 1)),
        max(
          String.length(build_token_label(subscription.token_address, subscription.chain_id)),
          Enum.at(acc, 2)
        ),
        max(String.length(if subscription.paused, do: "Paused", else: "Active"), Enum.at(acc, 3))
      ]
    end)
  end

  def build_token_label(token_address, chain_id) do
    symbol = get_token_sym(token_address, chain_id)

    case symbol do
      "" -> "#{truncate_address(token_address)}"
      _ -> "#{truncate_address(token_address)} (#{symbol})"
    end
  end

  defp truncate_address(address) do
    String.slice(address, 0..5) <> "..." <> String.slice(address, -4..-1)
  end

  defp format_row(values, widths) do
    row =
      Enum.map_join(Enum.zip(values, widths), " | ", fn {value, width} ->
        pad_right(value, width)
      end)

    "| " <> row <> " |"
  end

  defp format_separator(widths) do
    separator =
      Enum.map_join(widths, "+", fn width ->
        String.duplicate("-", width + 2)
      end)

    "+" <> separator <> "+"
  end

  defp format_subscription(%{chat_id: chat_id, token_address: token_address, chain_id: chain_id, paused: paused}, widths) do
    status = if paused, do: "Paused", else: "Active"

    values = [
      Integer.to_string(chat_id),
      BlockchainConfig.get_chain_label(chain_id),
      build_token_label(token_address, chain_id),
      status
    ]

    format_row(values, widths)
  end

  defp pad_right(string, length) do
    padding_length = max(length - String.length(string), 0)
    string <> String.duplicate(" ", padding_length)
  end

  def get_token_sym(token_address, chain_id) do
    query =
      from(s in BalancerSwap,
        where: (s.token_in == ^token_address or s.token_out == ^token_address) and s.chain_id == ^chain_id,
        select: %{
          token_in_sym: s.token_in_sym,
          token_out_sym: s.token_out_sym,
          token_in: s.token_in,
          token_out: s.token_out
        },
        limit: 1
      )

    case Repo.one(query) do
      nil -> ""
      %{token_in: ^token_address, token_in_sym: token_symbol} -> token_symbol
      %{token_out: ^token_address, token_out_sym: token_symbol} -> token_symbol
      _ -> "Unknown"
    end
  end
end
