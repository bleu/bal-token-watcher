defmodule SwapListener.Balancer.BalancerPoller do
  @moduledoc false
  use GenServer

  import Ecto.Query, only: [from: 2]

  alias SwapListener.Balancer.BalancerSwap
  alias SwapListener.Balancer.Pagination
  alias SwapListener.Common.BlockchainConfig
  alias SwapListener.Dexscreener.DexscreenerCache
  alias SwapListener.Infra.Repo

  require Logger

  @poll_interval :timer.seconds(10)
  @batch_size 100

  def start_link({network, url, chain_id}) do
    GenServer.start_link(__MODULE__, %{network: network, url: url, chain_id: chain_id},
      name: String.to_atom("BalancerPoller_#{network}")
    )
  end

  def init(state) do
    schedule_poll()
    {:ok, state}
  end

  def handle_info(:poll, state) do
    poll_balancer_subgraph(state)
    schedule_poll()
    {:noreply, state}
  end

  defp schedule_poll, do: Process.send_after(self(), :poll, @poll_interval)

  defp poll_balancer_subgraph(%{network: network, url: url, chain_id: chain_id}) do
    Logger.debug("Polling Balancer subgraph for #{network}")

    latest_timestamp = get_latest_timestamp(chain_id) || DateTime.to_unix(DateTime.utc_now()) - 10

    query = """
    query ($latestTimestamp: Int!) {
      swaps(first: #{@batch_size}, orderBy: timestamp, orderDirection: desc, where: {timestamp_gt: $latestTimestamp}) {
        id caller tokenIn tokenInSym tokenOut tokenOutSym tokenAmountIn tokenAmountOut valueUSD poolId { id } userAddress { id } timestamp block tx
      }
    }
    """

    variables = %{"latestTimestamp" => latest_timestamp}
    Pagination.paginate(url, query, &process_swaps(&1, chain_id), "", @batch_size, variables)
  end

  defp get_latest_timestamp(chain_id) do
    query = from(c in BalancerSwap, where: c.chain_id == ^chain_id, select: max(c.timestamp))

    query
    |> Repo.one()
    |> case do
      nil -> nil
      timestamp -> DateTime.to_unix(timestamp)
    end
  end

  defp process_swaps(data, chain_id) do
    swaps = Map.get(data, "swaps", [])
    Enum.each(swaps, &store_swap(&1, chain_id))
  end

  defp store_swap(swap, chain_id) do
    changeset = BalancerSwap.changeset(%BalancerSwap{}, swap_params(swap, chain_id))

    Repo.transaction(fn ->
      case Repo.insert(changeset) do
        {:ok, _swap} -> Logger.debug("Successfully inserted swap #{swap["id"]}")
        {:error, changeset} -> handle_insert_error(swap["id"], changeset)
      end
    end)
  end

  defp handle_insert_error(id, changeset) do
    if changeset.valid?,
      do: Logger.error("Failed to insert swap #{id}: #{inspect(changeset.errors)}"),
      else: Logger.debug("Swap #{id} already exists, skipping insertion")
  end

  defp swap_params(swap, chain_id) do
    %{
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
      chain_id: chain_id,
      dexscreener_url: get_or_fetch_dexscreener_url(chain_id, swap["tokenIn"], swap["tokenOut"]),
      tx_link: get_explorer_link(chain_id, swap["tx"]),
      deposit_link: get_pool_link(chain_id, swap["poolId"]["id"]),
      buy_link: get_buy_link(chain_id, swap["tokenIn"], swap["tokenOut"])
    }
  end

  defp get_buy_link(chain_id, token_in, token_out) do
    if chain_id in [1, 10],
      do: get_cowswap_link(chain_id, token_in, token_out),
      else: get_1inch_link(chain_id, token_in, token_out)
  end

  defp get_1inch_link(chain_id, token_in, token_out),
    do: "https://app.1inch.io/#/#{chain_id}/simple/swap/#{token_in}/#{token_out}"

  defp get_cowswap_link(chain_id, token_in, token_out),
    do: "https://swap.cow.fi/#/#{chain_id}/swap/#{token_in}/#{token_out}"

  defp get_explorer_link(chain_id, tx_hash),
    do: "#{Map.get(BlockchainConfig.chain_scanner_map(), chain_id, "https://etherscan.io")}/tx/#{tx_hash}"

  defp get_pool_link(chain_id, pool_id),
    do: "#{Map.get(BlockchainConfig.balancer_pool_map(), chain_id, "https://pools.balancer.exchange/#/pool/")}/#{pool_id}"

  defp get_or_fetch_dexscreener_url(chain_id, token_in, token_out) do
    query =
      from(d in DexscreenerCache,
        where: d.token_in == ^token_in and d.token_out == ^token_out and d.chain_id == ^chain_id
      )

    case Repo.all(query) do
      [dexscreener_cache] ->
        dexscreener_cache.dexscreener_url

      [] ->
        nil

      [_ | _] = results ->
        Logger.error("Multiple results found for token pair #{token_in} -> #{token_out} on chain #{chain_id}")
        List.first(results).dexscreener_url
    end
  end
end
