defmodule SwapListener.Repo.Migrations.CreateBalancerSwaps do
  use Ecto.Migration

  def change do
    create table(:balancer_swaps, primary_key: false) do
      add :id, :string, primary_key: true
      add :caller, :string
      add :token_in, :string
      add :token_in_sym, :string
      add :token_out, :string
      add :token_out_sym, :string
      add :token_amount_in, :decimal
      add :token_amount_out, :decimal
      add :value_usd, :decimal
      add :pool_id, :string
      add :user_address, :string
      add :timestamp, :utc_datetime
      add :block, :bigint
      add :tx, :string
      add :chain_id, :integer

      timestamps()
    end

    create index(:balancer_swaps, [:token_in])
    create index(:balancer_swaps, [:token_out])
    create index(:balancer_swaps, [:pool_id])
    create index(:balancer_swaps, [:user_address])
    create index(:balancer_swaps, [:chain_id])
  end
end
