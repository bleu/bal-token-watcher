defmodule SwapListener.Balancer.GraphQLClientImpl do
  @moduledoc """
  Implementation of GraphQL client.
  """
  @behaviour SwapListener.Balancer.GraphQLClient

  require Logger

  @headers [{"Content-Type", "application/json"}]

  def request(endpoint, query, variables \\ %{}) do
    body = Jason.encode!(%{query: query, variables: variables})

    case HTTPoison.post(endpoint, body, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("GraphQL request failed: HTTP #{status_code}, Response: #{body}")
        {:error, %{"status_code" => status_code, "body" => body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("GraphQL request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
