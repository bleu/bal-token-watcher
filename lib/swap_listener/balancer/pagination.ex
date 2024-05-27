defmodule SwapListener.Balancer.Pagination do
  @moduledoc """
  Handles paginated fetching of data from a GraphQL endpoint.
  """
  require Logger

  @graphql_client Application.compile_env(:swap_listener, :graphql_client, SwapListener.Balancer.GraphQLClientImpl)

  def paginate(endpoint, query, process_fn, initial_id \\ "", step \\ 1000, variables \\ %{}) do
    Logger.debug("Paginating data from endpoint: #{endpoint}")

    do_paginate(endpoint, query, process_fn, initial_id, step, variables)
  end

  defp do_paginate(endpoint, query, process_fn, latest_id, step, variables) do
    variables = Map.put(variables, :latestId, latest_id)

    case @graphql_client.request(endpoint, query, variables) do
      {:ok, %{"data" => data}} ->
        Logger.debug("Fetched data successfully: #{inspect(data)}")

        case process_fn.(data) do
          :ok ->
            ids = get_ids_from_data(data)

            if length(ids) < step do
              :done
            else
              do_paginate(endpoint, query, process_fn, List.last(ids), step, variables)
            end

          :done ->
            Logger.info("Reached end of pagination")
            :done

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
