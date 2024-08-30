defmodule SwapListener.Common.BlockchainConfig do
  @moduledoc false
  @chain_name_map %{
    1 => "Mainnet",
    137 => "Polygon",
    1101 => "PolygonzkEVM",
    42_161 => "Arbitrum",
    10 => "Optimism",
    100 => "Gnosis",
    43_114 => "Avalanche",
    8453 => "Base"
    # 250 => "Fantom"
  }

  @subgraph_urls %{
    1 => "https://api.studio.thegraph.com/query/75376/balancer-v2/version/latest",
    137 => "https://api.studio.thegraph.com/query/75376/balancer-polygon-v2/version/latest",
    1101 => "https://api.studio.thegraph.com/query/24660/balancer-polygon-zk-v2/version/latest",
    42_161 => "https://api.studio.thegraph.com/query/75376/balancer-arbitrum-v2/version/latest",
    10 => "https://api.studio.thegraph.com/query/75376/balancer-optimism-v2/version/latest",
    100 => "https://api.studio.thegraph.com/query/75376/balancer-gnosis-chain-v2/version/latest",
    43_114 => "https://api.studio.thegraph.com/query/75376/balancer-avalanche-v2/version/latest",
    8453 => "https://api.studio.thegraph.com/query/24660/balancer-base-v2/version/latest"
    # 250 => "https://api.thegraph.com/subgraphs/name/beethovenxfi/beethovenx"
  }

  @chain_scanner_map %{
    1 => "https://etherscan.io",
    137 => "https://polygonscan.com",
    1101 => "https://zkevm.polygonscan.com",
    42_161 => "https://arbiscan.io",
    10 => "https://optimistic.etherscan.io",
    100 => "https://gnosisscan.io",
    43_114 => "https://snowtrace.io",
    8453 => "https://basescan.org"
    # 250 => "https://ftmscan.com"
  }

  @balancer_pool_map %{
    1 => "https://app.balancer.fi/#/ethereum/pool",
    137 => "https://app.balancer.fi/#/polygon/pool",
    1101 => "https://app.balancer.fi/#/zkevm/pool",
    42_161 => "https://app.balancer.fi/#/arbitrum/pool",
    10 => "https://app.balancer.fi/#/optimism/pool",
    100 => "https://app.balancer.fi/#/gnosis-chain/pool",
    43_114 => "https://app.balancer.fi/#/avalanche/pool",
    8453 => "https://app.balancer.fi/#/base/pool"
    # 250 => "https://beets.fi/pool"
  }

  def subgraph_urls do
    Enum.map(@subgraph_urls, fn {chain_id, url} -> {Map.get(@chain_name_map, chain_id), url, chain_id} end)
  end

  def chain_scanner_map, do: @chain_scanner_map

  def balancer_pool_map, do: @balancer_pool_map
  def chain_name_map, do: @chain_name_map

  def get_chain_label(chain_id), do: "#{Map.get(@chain_name_map, chain_id)} (#{chain_id})"
end
