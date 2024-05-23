defmodule SwapListener.AllowList do
  @moduledoc false

  @allowed_users []

  def allowed?(username) do
    username in @allowed_users
  end
end
