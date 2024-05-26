defmodule SwapListener.Infra.Repo.Migrations.AddLanguageToChatSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:chat_subscriptions) do
      add :language, :string
    end
  end
end
