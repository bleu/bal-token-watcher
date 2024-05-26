defmodule SwapListener.ChatSubscription.ChatSubscription do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "chat_subscriptions" do
    field :chat_id, :integer
    field :chat_title, :string
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
    field :archived_at, :utc_datetime
    field :creator_id, :integer
    field :language, :string, default: "en"

    timestamps()
  end

  @required_fields ~w(chat_id token_address chain_id min_buy_amount trade_size_emoji trade_size_step creator_id language)a
  @optional_fields ~w(alert_image_url website_url twitter_handle discord_link telegram_link paused archived_at chat_title)a

  @doc false
  def changeset(chat_subscription, attrs) do
    chat_subscription
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> update_change(:token_address, &String.downcase/1)
  end
end
