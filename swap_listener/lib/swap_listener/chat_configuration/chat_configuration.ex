defmodule SwapListener.ChatConfiguration.ChatConfiguration do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "chat_configurations" do
    field :chat_id, :integer
    field :language, :string

    timestamps()
  end

  @required_fields ~w(chat_id language)a
  @optional_fields ~w()a

  def changeset(chat_configuration, attrs) do
    chat_configuration
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:chat_id)
  end
end
