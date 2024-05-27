defmodule SwapListener.Infra.Repo.Migrations.CreateChatSubscriptions do
  use Ecto.Migration

  def change do
    create table(:chat_subscriptions) do
      add :chat_id, :bigint
      add :token_address, :string
      add :chain_id, :integer
      add :min_buy_amount, :decimal
      add :trade_size_emoji, :string
      add :trade_size_step, :decimal
      add :alert_image_url, :string
      add :website_url, :string
      add :twitter_handle, :string
      add :discord_link, :string
      add :telegram_link, :string

      timestamps()
    end
  end
end
