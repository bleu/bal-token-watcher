defmodule SwapListener.Infra.Repo.Migrations.AddPausedToChatSubscription do
  use Ecto.Migration

  def change do
    alter table(:chat_subscriptions) do
      add :paused, :boolean, default: false, null: false
    end
  end
end
