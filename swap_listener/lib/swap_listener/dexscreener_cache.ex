defmodule SwapListener.DexscreenerCache do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "dexscreener_cache" do
    field :dexscreener_url, :string
    field :chain_id, :integer

    timestamps()
  end

  @doc false
  def changeset(cache, attrs) do
    cache
    |> cast(attrs, [:id, :dexscreener_url, :chain_id])
    |> validate_required([:id, :dexscreener_url, :chain_id])
  end
end
