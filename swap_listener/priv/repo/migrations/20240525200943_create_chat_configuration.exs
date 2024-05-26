defmodule SwapListener.Infra.Repo.Migrations.CreateChatConfiguration do
  use Ecto.Migration

  def change do
    create table(:chat_configurations) do
      add :chat_id, :bigint, null: false
      add :language, :string, null: false, default: "en"

      timestamps()
    end

    create unique_index(:chat_configurations, [:chat_id])
  end
end
