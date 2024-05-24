defmodule SwapListener.BalancerPoller do
  @moduledoc false
  use GenServer

  import Ecto.Query, only: [from: 2]

  alias SwapListener.BalancerSwap
  alias SwapListener.BlockchainConfig
  alias SwapListener.DexscreenerCache
  alias SwapListener.Pagination
  alias SwapListener.Repo

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

  def handle_info(:poll, %{network: network, url: url, chain_id: chain_id} = state) do
    Logger.debug("Polling Balancer subgraph for #{network}")
    poll_balancer_subgraph(url, chain_id)
    schedule_poll()
    {:noreply, state}
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp get_latest_timestamp(chain_id) do
    query = from(c in BalancerSwap, where: c.chain_id == ^chain_id, select: max(c.timestamp))

    case Repo.one(query) do
      nil -> nil
      timestamp -> DateTime.to_unix(timestamp)
    end
  end

  defp poll_balancer_subgraph(url, chain_id) do
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

  defp process_swaps(data, chain_id) do
    swaps = Map.get(data, "swaps", [])
    Enum.each(swaps, &store_swap(&1, chain_id))
  end

  defp store_swap(swap, chain_id) do
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
        chain_id: chain_id,
        dexscreener_url: get_or_fetch_dexscreener_url(chain_id, swap["tokenIn"], swap["tokenOut"]),
        tx_link: get_explorer_link(chain_id, swap["tx"]),
        deposit_link: get_pool_link(chain_id, swap["poolId"]["id"]),
        buy_link: get_buy_link(chain_id, swap["tokenIn"], swap["tokenOut"])
      })

    Repo.transaction(fn ->
      case Repo.insert(changeset) do
        {:ok, _swap} ->
          Logger.debug("Successfully inserted swap #{swap["id"]}")

        {:error, changeset} ->
          if changeset.valid? do
            Logger.error("Failed to insert swap #{swap["id"]}: #{inspect(changeset.errors)}")
          else
            Logger.debug("Swap #{swap["id"]} already exists, skipping insertion")
          end
      end
    end)
  end

  defp get_buy_link(chain_id, token_in, token_out) do
    cowswap_supported_chains = [1, 10]

    if Enum.member?(cowswap_supported_chains, chain_id) do
      get_cowswap_link(chain_id, token_in, token_out)
    else
      get_1inch_link(chain_id, token_in, token_out)
    end
  end

  defp get_1inch_link(chain_id, token_in, token_out) do
    base_url = "https://app.1inch.io"
    # ETH
    "#{base_url}/#/#{chain_id}/simple/swap/#{token_in}/#{token_out}"
  end

  defp get_cowswap_link(chain_id, token_in, token_out) do
    base_url = "https://swap.cow.fi"

    "#{base_url}/#/#{chain_id}/swap/#{token_in}/#{token_out}"
  end

  defp get_explorer_link(chain_id, tx_hash) do
    base_url = Map.get(BlockchainConfig.chain_scanner_map(), chain_id, "https://etherscan.io")
    "#{base_url}/tx/#{tx_hash}"
  end

  defp get_pool_link(chain_id, pool_id) do
    base_url =
      Map.get(
        BlockchainConfig.balancer_pool_map(),
        chain_id,
        "https://pools.balancer.exchange/#/pool/"
      )

    "#{base_url}#{pool_id}"
  end

  defp get_or_fetch_dexscreener_url(chain_id, token_in, token_out) do
    case Repo.get_by(DexscreenerCache, token_in: token_in, token_out: token_out, chain_id: chain_id) do
      nil ->
        nil

      %DexscreenerCache{dexscreener_url: url} ->
        url
    end
  end
end
