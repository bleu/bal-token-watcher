defmodule SwapListener.Infra.Repo.Migrations.AddLinksToBalancerSwap do
  use Ecto.Migration

  def change do
    alter table(:balancer_swaps) do
      add :buy_link, :string
      add :deposit_link, :string
      add :chart_link, :string
      add :tx_link, :string
    end
  end
end
