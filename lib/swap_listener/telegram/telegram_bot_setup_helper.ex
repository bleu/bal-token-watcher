defmodule SwapListener.Telegram.TelegramBotSetupHelper do
  @moduledoc false
  alias SwapListener.Telegram.TelegramClientImpl

  def get_commands do
    [
      {"start", "Start the bot and get a welcome message."},
      {"addtoken", "Begin the process to add a new token for buy alerts."},
      {"help", "Get detailed information about available commands."},
      {"manage", "Manage your subscriptions with various actions."},
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
