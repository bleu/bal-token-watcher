defmodule SwapListener.Repo.Migrations.AddIndexesToBalancerSwaps do
  use Ecto.Migration

  def change do
    create_if_not_exists(index(:balancer_swaps, [:user_address]))
    create_if_not_exists(index(:balancer_swaps, [:token_in]))
    create_if_not_exists(index(:balancer_swaps, [:token_out]))
    create_if_not_exists(index(:balancer_swaps, [:pool_id]))
    create_if_not_exists(index(:balancer_swaps, [:timestamp]))
    create_if_not_exists(index(:balancer_swaps, [:chain_id]))
    create_if_not_exists(index(:balancer_swaps, [:block]))
  end
end
