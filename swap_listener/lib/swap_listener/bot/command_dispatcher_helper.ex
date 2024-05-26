defmodule SwapListener.Bot.CommandsDispatcherHelper do
  @moduledoc false
  import SwapListener.I18n.Gettext

  alias SwapListener.Common.BlockchainConfig

  def available_chains_text do
    chains = BlockchainConfig.subgraph_urls()

    chains
    |> Enum.map_join("\n", fn {name, _, chain_id} -> "- #{name} (#{chain_id})" end)
    |> then(&("#{gettext("Available Chains:")}\n" <> &1))
  end
end
