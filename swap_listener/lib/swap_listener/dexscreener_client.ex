defmodule SwapListener.DexscreenerClient do
  @moduledoc """
  A client for fetching Dexscreener URLs for specific pairs.
  """
  require Logger

  @api_url "https://api.dexscreener.com/latest/dex/search"

  @dexscreener_chain_id_map %{
    1 => "ethereum",
    137 => "polygon",
    1101 => "polygonzkevm",
    42_161 => "arbitrum",
    100 => "optimism",
    10 => "gnosis",
    43_114 => "avalanche",
    8453 => "base"
  }

  @max_retries 5
  @initial_backoff 500

  defp get_dexscreener_chain_id(chain_id) do
    Map.get(@dexscreener_chain_id_map, chain_id, fn ->
      Logger.warning("No chain ID mapping found for chain ID #{chain_id}")
      nil
    end)
  end

  def get_dexscreener_url(chain_id, token_in, token_out) do
    url = "#{@api_url}?q=#{token_in}%20#{token_out}"
    fetch_with_retries(url, chain_id, token_in, token_out, @max_retries, @initial_backoff)
  end

  defp fetch_with_retries(_url, _chain_id, _token_in, _token_out, 0, _backoff) do
    Logger.error("Max retries reached, failing")
    nil
  end

  defp fetch_with_retries(url, chain_id, token_in, token_out, retries, backoff) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"pairs" => pairs}} ->
            chain_id_str = get_dexscreener_chain_id(chain_id)
            pair = Enum.find(pairs, fn pair -> pair["chainId"] == chain_id_str and pair["dexId"] == "balancer" end)

            (pair && [pair["pairAddress"], pair["url"]]) || nil

          {:error, reason} ->
            Logger.error("Failed to decode response: #{inspect(reason)}")
            nil
        end

      {:ok, %HTTPoison.Response{status_code: 429}} ->
        Logger.warning("Received 429 Too Many Requests. Retrying in #{backoff} ms...")
        :timer.sleep(backoff)
        fetch_with_retries(url, chain_id, token_in, token_out, retries - 1, backoff * 2)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("Failed to fetch URL: #{url}. Status code: #{status_code}. Body: #{body}")
        nil

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Failed to fetch URL: #{url}. Reason: #{inspect(reason)}")
        nil
    end
  end
end
