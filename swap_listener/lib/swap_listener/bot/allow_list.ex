defmodule SwapListener.Bot.AllowList do
  @moduledoc false

  @allowed_users ["rpunktj", "burns_unit", "tritium_vlk"]

  def allowed?(username) do
    username in @allowed_users
  end
end
