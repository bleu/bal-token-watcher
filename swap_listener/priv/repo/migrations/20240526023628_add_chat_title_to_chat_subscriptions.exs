defmodule SwapListener.Infra.Repo.Migrations.AddChatTitleToChatSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:chat_subscriptions) do
      add :chat_title, :string
    end
  end
end
