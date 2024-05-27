defmodule SwapListener.Repo.Migrations.AddLinksToChatSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:chat_subscriptions) do
      add :links, {:array, :map}, default: []
    end
  end
end
