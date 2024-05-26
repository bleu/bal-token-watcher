defmodule SwapListener.Infra.Repo.Migrations.CreateDexscreenerCache do
  use Ecto.Migration

  def change do
    create table(:dexscreener_cache, primary_key: false) do
      add :id, :string, primary_key: true
      add :dexscreener_url, :string
      add :chain_id, :integer

      timestamps()
    end

    create index(:dexscreener_cache, [:chain_id])
  end
end
