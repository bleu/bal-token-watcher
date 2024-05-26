defmodule SwapListener.Dexscreener.DexscreenerCache do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "dexscreener_cache" do
    field :token_in, :string
    field :token_out, :string
    field :chain_id, :integer
    field :dexscreener_url, :string

    timestamps()
  end

  @doc false
  def changeset(cache, attrs) do
    cache
    |> cast(attrs, [:id, :dexscreener_url, :chain_id])
    |> validate_required([:id, :dexscreener_url, :chain_id])
    |> unique_constraint(:id, name: :dexscreener_cache_pkey)
  end
end
