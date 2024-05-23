defmodule SwapListener.CommandHandler.Utils do
  @moduledoc false
  import Ecto.Query, only: [from: 2]

  alias SwapListener.BalancerSwap
  alias SwapListener.BlockchainConfig
  alias SwapListener.Repo

  def format_subscription_table(subscriptions) do
    headers = ["Chain", "Token (Symbol)", "Status"]

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
      - Chain: #{BlockchainConfig.get_chain_label(subscription.chain_id)}
        Token: #{subscription.token_address} (#{get_token_sym(subscription.token_address, subscription.chain_id)})
        Status: #{if subscription.paused, do: "Paused", else: "Active"}
      """
    end)
  end

  defp calculate_column_widths(headers, subscriptions) do
    initial_widths = Enum.map(headers, &String.length/1)

    Enum.reduce(subscriptions, initial_widths, fn subscription, acc ->
      [
        max(String.length(BlockchainConfig.get_chain_label(subscription.chain_id)), Enum.at(acc, 0)),
        max(
          String.length(
            "#{truncate_address(subscription.token_address)} (#{get_token_sym(subscription.token_address, subscription.chain_id)})"
          ),
          Enum.at(acc, 1)
        ),
        max(String.length(if subscription.paused, do: "Paused", else: "Active"), Enum.at(acc, 2))
      ]
    end)
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

  defp format_subscription(%{token_address: token_address, chain_id: chain_id, paused: paused}, widths) do
    status = if paused, do: "Paused", else: "Active"

    values = [
      BlockchainConfig.get_chain_label(chain_id),
      "#{truncate_address(token_address)} (#{get_token_sym(token_address, chain_id)})",
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
      nil -> "Unknown"
      %{token_in: ^token_address, token_in_sym: token_symbol} -> token_symbol
      %{token_out: ^token_address, token_out_sym: token_symbol} -> token_symbol
      _ -> "Unknown"
    end
  end
end
