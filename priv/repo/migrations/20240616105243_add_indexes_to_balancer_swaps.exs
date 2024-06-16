defmodule SwapListener.Repo.Migrations.AddIndexesToBalancerSwaps do
  use Ecto.Migration

  def change do
    create(index(:balancer_swaps, [:user_address]))
    create(index(:balancer_swaps, [:token_in]))
    create(index(:balancer_swaps, [:token_out]))
    create(index(:balancer_swaps, [:pool_id]))
    create(index(:balancer_swaps, [:timestamp]))
    create(index(:balancer_swaps, [:chain_id]))
    create(index(:balancer_swaps, [:block]))
  end
end
