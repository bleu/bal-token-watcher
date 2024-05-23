defmodule SwapListener.Repo.Migrations.AddTokenInTokenOutToDexscreenerCache do
  use Ecto.Migration

  def change do
    alter table(:dexscreener_cache) do
      add :token_in, :string
      add :token_out, :string
    end
  end
end
