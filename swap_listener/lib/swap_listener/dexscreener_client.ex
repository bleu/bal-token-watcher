defmodule SwapListener.DexscreenerClient do
  @moduledoc """
  A client for fetching Dexscreener URLs for specific pairs.
  """
  require Logger

  @api_url "https://api.dexscreener.com/latest/dex/pairs"

  def get_pair_url(chain_id, pair_address) do
    url = "#{@api_url}/#{chain_id}/#{pair_address}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"pairs" => [pair | _]}} ->
            {:ok, pair["url"]}

          {:ok, _} ->
            {:error, "No pairs found"}

          {:error, _} = error ->
            error
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch Dexscreener URL: HTTP #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
