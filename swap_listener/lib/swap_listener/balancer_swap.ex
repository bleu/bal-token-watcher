defmodule SwapListener.BalancerSwap do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "balancer_swaps" do
    field :caller, :string
    field :token_in, :string
    field :token_in_sym, :string
    field :token_out, :string
    field :token_out_sym, :string
    field :token_amount_in, :decimal
    field :token_amount_out, :decimal
    field :value_usd, :decimal
    field :pool_id, :string
    field :user_address, :string
    field :timestamp, :utc_datetime
    field :block, :integer
    field :tx, :string
    field :chain_id, :integer
    field :dexscreener_url, :string
    field :tx_link, :string
    field :deposit_link, :string
    field :buy_link, :string

    timestamps()
  end

  @spec changeset(
          {map(), map()}
          | %{
              :__struct__ => atom() | %{:__changeset__ => map(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(swap, attrs) do
    swap
    |> cast(attrs, [
      :id,
      :caller,
      :token_in,
      :token_in_sym,
      :token_out,
      :token_out_sym,
      :token_amount_in,
      :token_amount_out,
      :dexscreener_url,
      :value_usd,
      :pool_id,
      :user_address,
      :timestamp,
      :block,
      :tx,
      :chain_id,
      :tx_link,
      :deposit_link,
      :buy_link
    ])
    |> validate_required([
      :id,
      :caller,
      :token_in,
      :token_out,
      :token_amount_in,
      :token_amount_out,
      :value_usd,
      :pool_id,
      :user_address,
      :timestamp,
      :tx,
      :chain_id
    ])
    |> unique_constraint(:id, name: :balancer_swaps_pkey)
  end
end
