defmodule SwapListener.Repo.Migrations.ChangeCreatorIdToBigintInChatSubscriptions do
  use Ecto.Migration

  def up do
    alter table(:chat_subscriptions) do
      modify :creator_id, :bigint
    end
  end

  def down do
    alter table(:chat_subscriptions) do
      modify :creator_id, :integer
    end
  end
end
