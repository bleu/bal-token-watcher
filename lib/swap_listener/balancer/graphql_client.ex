defmodule SwapListener.Balancer.GraphQLClient do
  @moduledoc """
  Behavior for GraphQL client.
  """
  @callback request(String.t(), String.t(), map()) :: {:ok, map()} | {:error, any()}
end
