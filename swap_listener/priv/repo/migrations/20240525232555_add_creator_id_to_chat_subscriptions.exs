defmodule SwapListener.Repo.Migrations.AddCreatorIdToChatSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:chat_subscriptions) do
      add :creator_id, :integer
    end
  end
end
