defmodule SwapListener.Telegram.TelegramBotSetupHelper do
  @moduledoc false
  alias SwapListener.Telegram.TelegramClientImpl

  def get_commands do
    [
      {"start", "Welcome to the Balancer Buy Bot. Type `/help` for more information."},
      {"addtoken", "Begin the process to add a new token for buy alerts."},
      {"help", "Get detailed information about a specific command."},
      {"manage", "Manage your subscriptions."},
      {"example", "Get an example message."}
    ]
  end

  def set_my_commands do
    commands = get_commands()

    formatted_commands =
      Enum.map(commands, fn {command, description} ->
        %{command: command, description: description}
      end)

    TelegramClientImpl.set_my_commands(formatted_commands)
  end
end
