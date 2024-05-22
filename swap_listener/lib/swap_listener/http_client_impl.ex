defmodule SwapListener.HttpClientImpl do
  @moduledoc false
  @behaviour SwapListener.HttpClient

  def get(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
