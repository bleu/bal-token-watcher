defmodule SwapListener.CommandHandlerHelper do
  @moduledoc false
  alias SwapListener.BlockchainConfig

  def available_chains_text do
    chains = BlockchainConfig.subgraph_urls()

    chains
    |> Enum.map_join("\n", fn {name, _, chain_id} -> "- #{name} (#{chain_id})" end)
    |> then(&("\n*Available Chains:*\n" <> &1))
  end
end
