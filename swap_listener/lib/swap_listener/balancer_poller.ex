defmodule SwapListener.BalancerPoller do
  @moduledoc false
  use GenServer

  alias SwapListener.BalancerSwap
  alias SwapListener.Pagination
  alias SwapListener.Repo

  require IEx
  require Logger

  @poll_interval :timer.seconds(10)
  @batch_size 10

  def start_link({network, url, chain_id}) do
    GenServer.start_link(__MODULE__, %{network: network, url: url, chain_id: chain_id},
      name: String.to_atom("BalancerPoller_#{network}")
    )
  end

  def init(state) do
    schedule_poll()
    {:ok, state}
  end

  def handle_info(:poll, %{network: network, url: url, chain_id: chain_id} = state) do
    Logger.debug("Polling Balancer subgraph for #{network}")
    poll_balancer_subgraph(url, chain_id)
    schedule_poll()
    {:noreply, state}
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp poll_balancer_subgraph(url, chain_id) do
    query = """
    query ($latestId: ID!) {
      swaps(first: #{@batch_size}, orderBy: timestamp, orderDirection: desc, where: {id_gt: $latestId}) {
        id
        caller
        tokenIn
        tokenInSym
        tokenOut
        tokenOutSym
        tokenAmountIn
        tokenAmountOut
        valueUSD
        poolId {
          id
        }
        userAddress {
          id
        }
        timestamp
        block
        tx
      }
    }
    """

    Pagination.paginate(url, query, &process_swaps(&1, chain_id), "", @batch_size)
  end

  defp process_swaps(data, chain_id) do
    swaps = Map.get(data, "swaps", [])

    if swaps != [] do
      Enum.each(swaps, &store_swap(&1, chain_id))
      :ok
    else
      :done
    end
  end

  defp store_swap(swap, chain_id) do
    case Repo.get_by(BalancerSwap, id: swap["id"]) do
      nil ->
        changeset =
          BalancerSwap.changeset(%BalancerSwap{}, %{
            id: swap["id"],
            caller: swap["caller"],
            token_in: swap["tokenIn"],
            token_in_sym: swap["tokenInSym"],
            token_out: swap["tokenOut"],
            token_out_sym: swap["tokenOutSym"],
            token_amount_in: Decimal.new(swap["tokenAmountIn"]),
            token_amount_out: Decimal.new(swap["tokenAmountOut"]),
            value_usd: Decimal.new(swap["valueUSD"]),
            pool_id: swap["poolId"]["id"],
            user_address: swap["userAddress"]["id"],
            timestamp: DateTime.from_unix!(swap["timestamp"]),
            block: swap["block"],
            tx: swap["tx"],
            chain_id: chain_id
          })

        case Repo.insert(changeset) do
          {:ok, _swap} ->
            Logger.debug("Successfully inserted swap #{swap["id"]}")

          {:error, changeset} ->
            Logger.error("Failed to insert swap #{swap["id"]}: #{inspect(changeset.errors)}")
        end

      _swap ->
        Logger.debug("Swap #{swap["id"]} already exists, skipping insertion")
    end
  end
end
