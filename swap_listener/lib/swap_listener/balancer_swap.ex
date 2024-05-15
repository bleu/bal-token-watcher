defmodule SwapListener.BalancerSwap do
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

    timestamps()
  end

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
      :value_usd,
      :pool_id,
      :user_address,
      :timestamp,
      :block,
      :tx,
      :chain_id
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
  end
end
