defmodule SwapListener.Repo.Migrations.AddArchivedAtToChatSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:chat_subscriptions) do
      add :archived_at, :utc_datetime
    end
  end
end
