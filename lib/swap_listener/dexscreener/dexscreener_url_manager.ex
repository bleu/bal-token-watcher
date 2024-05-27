defmodule SwapListener.Dexscreener.DexscreenerUrlManager do
  @moduledoc false
  use GenServer

  import Ecto.Query, only: [from: 2]

  alias SwapListener.Balancer.BalancerSwap
  alias SwapListener.Dexscreener.DexscreenerCache
  alias SwapListener.Dexscreener.DexscreenerClient
  alias SwapListener.Infra.Repo

  require Logger

  @poll_interval :timer.seconds(10)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_poll()
    {:ok, state}
  end

  def handle_info(:poll, state) do
    fetch_and_process_swaps()
    schedule_poll()
    {:noreply, state}
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp fetch_and_process_swaps do
    swaps_without_urls = fetch_swaps_without_urls()

    swaps_without_urls
    |> Enum.shuffle()
    |> Enum.each(&fetch_and_update_url/1)
  end

  defp fetch_swaps_without_urls do
    query =
      from(s in BalancerSwap,
        where: is_nil(s.dexscreener_url),
        select: %{
          id: s.id,
          token_in: s.token_in,
          token_out: s.token_out,
          chain_id: s.chain_id
        },
        distinct: [s.token_in, s.token_out, s.chain_id]
      )

    Repo.all(query)
  end

  defp fetch_and_update_url(details) do
    case DexscreenerClient.get_dexscreener_url(details.chain_id, details.token_in, details.token_out) do
      nil -> :ok
      [pair_address, url] -> add_dexscreener_pair(details, pair_address, url)
    end
  end

  defp add_dexscreener_pair(details, pair_address, url) do
    Repo.transaction(fn ->
      cache_changeset = %DexscreenerCache{
        id: pair_address,
        token_in: details.token_in,
        token_out: details.token_out,
        chain_id: details.chain_id,
        dexscreener_url: url
      }

      case Repo.insert(cache_changeset,
             on_conflict: [set: [dexscreener_url: url]],
             conflict_target: [:id]
           ) do
        {:ok, _} -> :ok
        {:error, _} -> :error
      end
    end)
  end
end
