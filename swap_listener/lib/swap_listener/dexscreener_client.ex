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

  defp get_dexscreener_chain_id(chain_id) do
    Map.get(@dexscreener_chain_id_map, chain_id, fn ->
      Logger.warning("No chain ID mapping found for chain ID #{chain_id}")
      nil
    end)
  end

  def get_dexscreener_url(chain_id, token_in, token_out) do
    url = "#{@api_url}?q=#{token_in}%20#{token_out}"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, %{"pairs" => pairs}} <- Jason.decode(body) do
      chain_id_str = get_dexscreener_chain_id(chain_id)
      pair = Enum.find(pairs, fn pair -> pair["chainId"] == chain_id_str and pair["dexId"] == "balancer" end)

      Logger.info("Found pair for #{token_in}/#{token_out} on chain #{chain_id}: #{inspect(pair)}")

      (pair && [pair["pairAddress"], pair["url"]]) || nil
    else
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Failed to fetch URL: #{url}. Reason: #{inspect(reason)}")
        nil

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("Failed to fetch URL: #{url}. Status code: #{status_code}. Body: #{body}")
        nil

      {:error, reason} ->
        Logger.error("Failed to decode response: #{inspect(reason)}")
        nil

      nil ->
        Logger.warning("No pair found for #{token_in}/#{token_out} on chain #{chain_id}")
        nil
    end
  end
end
