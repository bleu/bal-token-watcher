defmodule SwapListener.TelegramBotSetupHelper do
  @moduledoc false
  @commands %{
    "start" => "Welcome to the Balancer Buy Bot. Type `/help` for more information.",
    "subscribe" => "Subscribe to buy alerts for a specific token on a specified chain.",
    "unsubscribe" => "Unsubscribe from alerts for a specific token on a specified chain.",
    "unsubscribeall" => "Unsubscribe from all token alerts.",
    "subscriptions" => "List your current subscriptions.",
    "settings" => "Update bot settings for a specific subscription.",
    "pause" => "Pause alerts for a specific token on a specified chain.",
    "pauseall" => "Pause all token alerts.",
    "restart" => "Restart alerts for a specific token on a specified chain.",
    "restartall" => "Restart all paused alerts.",
    "addtoken" => "Begin the process to add a new token for buy alerts.",
    "help" => "Get detailed information about a specific command."
  }

  def get_commands, do: @commands
end
