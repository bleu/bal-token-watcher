defmodule SwapListener.Pagination do
  @moduledoc """
  Handles paginated fetching of data from a GraphQL endpoint.
  """
  alias SwapListener.GraphQLClient

  require Logger

  def paginate(endpoint, query, process_fn, initial_id \\ "", step \\ 1000, variables \\ %{}) do
    do_paginate(endpoint, query, process_fn, initial_id, step, variables)
  end

  defp do_paginate(endpoint, query, process_fn, latest_id, step, variables) do
    variables = Map.put(variables, :latestId, latest_id)

    case GraphQLClient.request(endpoint, query, variables) do
      {:ok, %{"data" => data}} ->
        Logger.debug("Fetched data successfully: #{inspect(data)}")

        case process_fn.(data) do
          :ok ->
            ids = get_ids_from_data(data)

            if length(ids) < step,
              do: :done,
              else: do_paginate(endpoint, query, process_fn, List.last(ids), step, variables)

          error ->
            Logger.error("Failed to process data: #{inspect(error)}")
            :error
        end

      {:error, error} ->
        Logger.error("Failed to fetch data: #{inspect(error)}")
        :error
    end
  end

  defp get_ids_from_data(data) do
    data
    |> Map.values()
    |> List.flatten()
    |> Enum.map(& &1["id"])
  end
end
