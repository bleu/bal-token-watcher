defmodule SwapListener.ChatSubscription do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "chat_subscriptions" do
    field :chat_id, :integer
    field :token_address, :string
    field :chain_id, :integer
    field :min_buy_amount, :decimal
    field :trade_size_emoji, :string
    field :trade_size_step, :decimal
    field :alert_image_url, :string
    field :website_url, :string
    field :twitter_handle, :string
    field :discord_link, :string
    field :telegram_link, :string
    field :paused, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(chat_subscription, attrs) do
    chat_subscription
    |> cast(attrs, [
      :chat_id,
      :token_address,
      :chain_id,
      :min_buy_amount,
      :trade_size_emoji,
      :trade_size_step,
      :alert_image_url,
      :website_url,
      :twitter_handle,
      :discord_link,
      :telegram_link,
      :paused
    ])
    |> validate_required([
      :chat_id,
      :token_address,
      :chain_id,
      :min_buy_amount,
      :trade_size_emoji,
      :trade_size_step
    ])
  end
end
