defmodule SwapListener.BlockchainConfig do
  @chain_name_map %{
    1 => "Ethereum Mainnet",
    137 => "Polygon",
    1101 => "Polygon zkEVM",
    42161 => "Arbitrum",
    100 => "Optimism",
    10 => "Gnosis Chain",
    43114 => "Avalanche",
    8453 => "Base",
    11_155_111 => "Sepolia"
  }

  @subgraph_urls %{
    1 => "https://api.thegraph.com/subgraphs/name/balancer-labs/balancer-v2",
    137 => "https://api.thegraph.com/subgraphs/name/balancer-labs/balancer-polygon-v2",
    1101 => "https://api.studio.thegraph.com/query/24660/balancer-polygon-zk-v2/version/latest",
    42161 => "https://api.thegraph.com/subgraphs/name/balancer-labs/balancer-arbitrum-v2",
    100 => "https://api.thegraph.com/subgraphs/name/balancer-labs/balancer-optimism-v2",
    10 => "https://api.thegraph.com/subgraphs/name/balancer-labs/balancer-gnosis-chain-v2",
    43114 => "https://api.thegraph.com/subgraphs/name/balancer-labs/balancer-avalanche-v2",
    8453 => "https://api.studio.thegraph.com/query/24660/balancer-base-v2/version/latest",
    11_155_111 => "https://api.studio.thegraph.com/query/24660/balancer-sepolia-v2/version/latest"
  }

  @chain_scanner_map %{
    1 => "https://etherscan.io",
    137 => "https://polygonscan.com",
    1101 => "https://zkevm.polygonscan.com",
    42161 => "https://arbiscan.io",
    100 => "https://gnosisscan.io",
    10 => "https://optimistic.etherscan.io",
    43114 => "https://snowtrace.io",
    8453 => "https://basescan.org",
    11_155_111 => "https://sepolia.etherscan.io"
  }

  @balancer_pool_map %{
    1 => "https://pools.balancer.exchange/#/pool/",
    137 => "https://pools.balancer.exchange/#/pool/",
    1101 => "https://pools.balancer.exchange/#/pool/",
    42161 => "https://pools.balancer.exchange/#/pool/",
    100 => "https://pools.balancer.exchange/#/pool/",
    10 => "https://pools.balancer.exchange/#/pool/",
    43114 => "https://pools.balancer.exchange/#/pool/",
    8453 => "https://pools.balancer.exchange/#/pool/",
    11_155_111 => "https://pools.balancer.exchange/#/pool/"
  }

  def subgraph_urls do
    @subgraph_urls
    |> Enum.map(fn {chain_id, url} ->
      {Map.get(@chain_name_map, chain_id), url, chain_id}
    end)
  end

  def chain_scanner_map, do: @chain_scanner_map

  def balancer_pool_map, do: @balancer_pool_map
end
