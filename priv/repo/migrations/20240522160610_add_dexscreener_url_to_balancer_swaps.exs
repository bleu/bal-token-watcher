defmodule SwapListener.Infra.Repo.Migrations.AddDexscreenerUrlToBalancerSwaps do
  use Ecto.Migration

  def change do
    alter table(:balancer_swaps) do
      add :dexscreener_url, :string
    end
  end
end
