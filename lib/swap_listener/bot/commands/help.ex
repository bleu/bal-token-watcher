defmodule SwapListener.Bot.Commands.Help do
  @moduledoc false
  import SwapListener.I18n.Gettext

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  @commands %{
    "/start" => gettext("Welcome to the SwapListener Bot. Type `/help` for more information."),
    "/addtoken" => gettext("Begin the process to add a new token for buy alerts."),
    "/manage" =>
      gettext("Manage your subscriptions. You can pause, restart, or unsubscribe from individual or all subscriptions."),
    "/help" =>
      gettext(
        "You're really into this, aren't you? 😄 Here’s a help for your help: just keep adding 'help' to go deeper. Example: `/help help help`"
      ),
    "/example" => gettext("Get an example message.")
  }

  def handle(chat_id, _user_id, ["help" | _] = args, state) do
    send_command_help(chat_id, "/help " <> Enum.join(args, " "))
    {state, nil}
  end

  def handle(chat_id, _user_id, [command], state) when command != "help" do
    send_command_help(chat_id, "/" <> command)
    {state, nil}
  end

  def handle(chat_id, _user_id, [], state) do
    send_help_message(chat_id)
    {state, nil}
  end

  defp send_command_help(chat_id, command) do
    message =
      if String.contains?(command, "/help help") do
        recursive_help()
      else
        @commands[command] ||
          gettext("Unknown command. Please type /help for a list of available commands.")
      end

    @telegram_client.send_message(chat_id, message)
  end

  defp recursive_help do
    gettext("🤯 Are you trying to break me? Just kidding, ask away! But seriously, type /help for the command list.")
  end

  defp send_help_message(chat_id) do
    message = """
    #{gettext("*Welcome to the SwapListener Bot!* Here’s how you can interact with me:")}

    - #{gettext("*`/start`*: Welcome message and initial setup.")}
    - #{gettext("*`/addtoken`*: Begin the process to add a new token for buy alerts. Follow the prompts to configure settings for the token.")}
    - #{gettext("*`/manage`*: Manage your subscriptions. You can pause, restart, or unsubscribe from individual or all subscriptions.")}
    - #{gettext("*`/help [command]`*: Get detailed information about a specific command. Just add the command after `/help`.")}

    #{gettext("Use these commands to stay updated on token trades and manage your alert preferences.")}
    """

    @telegram_client.send_message(chat_id, message)
  end
end
