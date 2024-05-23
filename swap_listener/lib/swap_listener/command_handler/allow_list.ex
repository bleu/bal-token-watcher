defmodule SwapListener.AllowList do
  @moduledoc false

  @allowed_users ["allowed_user1", "allowed_user2", "rpunktj"]

  def allowed?(username) do
    username in @allowed_users
  end
end
