defmodule SwapListener.ChatSubscription.ChatSubscription do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "chat_subscriptions" do
    field :chat_id, :integer
    field :chat_title, :string
    field :token_address, :string
    field :chain_id, :integer
    field :min_buy_amount, :decimal, default: 1.0
    field :trade_size_emoji, :string, default: "🚀"
    field :trade_size_step, :decimal, default: 1.0
    field :alert_image_url, :string
    field :website_url, :string
    field :twitter_handle, :string
    field :discord_link, :string
    field :telegram_link, :string

    field :links, {:array, :map},
      default: [
        %{
          "id" => "tx",
          "label" => "TX",
          "default" => true,
          "status" => "enabled"
        },
        %{
          "id" => "buy",
          "label" => "Buy",
          "default" => true,
          "status" => "enabled"
        },
        %{
          "id" => "deposit",
          "label" => "Deposit",
          "default" => true,
          "status" => "enabled"
        },
        %{
          "id" => "chart",
          "label" => "Chart",
          "default" => true,
          "status" => "enabled"
        }
      ]

    field :paused, :boolean, default: false
    field :archived_at, :utc_datetime
    field :creator_id, :integer
    field :language, :string, default: "en"

    timestamps()
  end

  @required_fields ~w(chat_id token_address chain_id min_buy_amount trade_size_emoji trade_size_step creator_id language)a
  @optional_fields ~w(alert_image_url website_url twitter_handle discord_link telegram_link paused archived_at chat_title links)a

  def changeset(chat_subscription, attrs) do
    chat_subscription
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> update_change(:token_address, &String.downcase/1)
    |> update_change(:chat_title, &String.trim/1)
    |> update_change(:trade_size_emoji, &String.trim/1)
    |> update_change(:min_buy_amount, &Decimal.new/1)
    |> update_change(:trade_size_step, &Decimal.new/1)
    |> validate_format(:token_address, ~r/^0x[a-fA-F0-9]{40}$/)
  end
end
