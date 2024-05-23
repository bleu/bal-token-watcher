defmodule SwapListener.CommandHandler.Help do
  @moduledoc false
  alias SwapListener.CommandHandlerHelper

  @telegram_client Application.compile_env(:swap_listener, :telegram_client, SwapListener.RateLimitedTelegramClientImpl)

  @commands %{
    "/start" => "*Welcome to the Balancer Buy Bot.* Type `/help` for more information.",
    "/subscribe" => """
    *Subscribe to Buy Alerts*
    `/subscribe [token_address] [chain_id]` - Subscribe to buy alerts for a specific token on a specified chain.
    *Example:* `/subscribe 0xTokenAddress 1`
    #{CommandHandlerHelper.available_chains_text()}
    """,
    "/unsubscribe" => """
    *Unsubscribe from Buy Alerts*
    `/unsubscribe [token_address] [chain_id]` - Unsubscribe from alerts for a specific token on a specified chain.
    *Example:* `/unsubscribe 0xTokenAddress 1`
    """,
    "/unsubscribeall" => "*Unsubscribe from All Token Alerts.*",
    "/subscriptions" => "*List Your Current Subscriptions.* Shows all tokens you are tracking and their settings.",
    "/settings" => """
    *Update Bot Settings*
    `/settings [token_address] [chain_id] [option:value]` - Update your bot settings for a specific subscription.
    *Options Include:*
    `min_buy_amount`, `trade_size_emoji`, `trade_size_step`, `alert_image_url`, `website_url`, `twitter_handle`, `discord_link`, `telegram_link`
    *Example:* `/settings 0xTokenAddress 1 min_buy_amount:100`
    """,
    "/pause" => """
    *Pause Alerts for a Specific Token*
    `/pause [token_address] [chain_id]` - Pause alerts for a specific token on a specified chain.
    *Example:* `/pause 0xTokenAddress 1`
    """,
    "/pauseall" => "*Pause All Token Alerts.*",
    "/restart" => """
    *Restart Alerts for a Specific Token*
    `/restart [token_address] [chain_id]` - Restart alerts for a specific token on a specified chain.
    *Example:* `/restart 0xTokenAddress 1`
    """,
    "/restartall" => "*Restart All Paused Alerts.*",
    "/addtoken" => """
    *Add a New Token for Buy Alerts*
    `/addtoken` - Begin the process to add a new token. You will be prompted to enter the chain ID, token address, and configure settings.
    """,
    "/help" =>
      "You're really into this, aren't you? 😄 Here’s a help for your help: just keep adding 'help' to go deeper. Example: `/help help help`"
  }

  def handle(chat_id, ["help" | _] = args, state) do
    send_command_help(chat_id, "/help " <> Enum.join(args, " "))
    {state, nil}
  end

  def handle(chat_id, [command], state) when command != "help" do
    send_command_help(chat_id, "/" <> command)
    {state, nil}
  end

  def handle(chat_id, [], state) do
    send_help_message(chat_id)
    {state, nil}
  end

  defp send_command_help(chat_id, command) do
    message =
      if String.contains?(command, "/help help") do
        recursive_help()
      else
        @commands[command] ||
          "Unknown command. Please type /help for a list of available commands."
      end

    @telegram_client.send_message(chat_id, message)
  end

  defp recursive_help do
    "🤯 Are you trying to break me? Just kidding, ask away! But seriously, type /help for the command list."
  end

  defp send_help_message(chat_id) do
    message = """
    *Welcome to the Balancer Buy Bot!* Here’s how you can interact with me:

    - *`/addtoken`*: Start the process to add a new token for buy alerts. Follow the prompts to configure settings for the token.
    - *`/subscribe [token_address] [chain_id]`*: Subscribe to buy alerts for a specific token. Specify the token address and the chain.
    - *`/unsubscribe [token_address] [chain_id]`*: Unsubscribe from alerts for a specific token on a specified chain.
    - *`/unsubscribeAll`*: Unsubscribe from all alerts.
    - *`/pause [token_address] [chain_id]`*: Pause alerts for a specific token on a specified chain.
    - *`/pauseAll`*: Pause all alerts.
    - *`/restart [token_address] [chain_id]`*: Restart alerts for a specific token on a specified chain.
    - *`/restartAll`*: Restart all paused alerts.
    - *`/subscriptions`*: View a list of all your current token subscriptions and their specific settings.
    - *`/settings [option:value]`*: Modify settings for notifications. Available options include `min_buy_amount`, `trade_size_emoji`, etc. Example: `/settings min_buy_amount:50`.
    - *`/help [command]`*: Get detailed information about a specific command. Just add the command after `/help`.

    Use these commands to stay updated on token trades and manage your alert preferences.
    """

    @telegram_client.send_message(chat_id, message)
  end
end
