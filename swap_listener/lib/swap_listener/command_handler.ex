defmodule SwapListener.CommandHandler do
  alias SwapListener.{ChatSubscriptionManager, TelegramClient}
  require Logger

  @commands %{
    "/start" => "*Welcome to the Balancer Buy Bot.* Type `/help` for more information.",
    "/subscribe" => """

    *Subscribe to Buy Alerts*

    `/subscribe [token_address] [chain_id]` - Subscribe to buy alerts for a specific token on a specified chain.



    *Example:* `/subscribe 0xTokenAddress 1`



    *Available Chains:*

    - Ethereum (1)

    - Polygon (137)

    - Arbitrum (42161)

    - Optimism (10)

    - Gnosis Chain (100)

    """,
    "/unsubscribe" => """

    *Unsubscribe from Buy Alerts*

    `/unsubscribe [token_address] [chain_id]` - Unsubscribe from alerts for a specific token on a specified chain.



    *Example:* `/unsubscribe 0xTokenAddress 1`

    """,
    "/unsubscribeAll" => "*Unsubscribe from All Token Alerts.*",
    "/subscriptions" =>
      "*List Your Current Subscriptions.* Shows all tokens you are tracking and their settings.",
    "/settings" => """

    *Update Bot Settings*

    `/settings [option:value]` - Update your bot settings for notifications.



    *Options Include:*

    `min_buy_amount`, `trade_size_emoji`, `trade_size_step`, `alert_image_url`, `website_url`, `twitter_handle`, `discord_link`, `telegram_link`



    *Example:* `/settings min_buy_amount:100`

    """,
    "/addToken" => """

    *Add a New Token for Buy Alerts*

    `/addToken` - Begin the process to add a new token. You will be prompted to enter the token address, select a chain, and configure settings.

    """,
    "/help" =>
      "You're really into this, aren't you? 😄 Here’s a help for your help: just keep adding 'help' to go deeper. Example: `/help help help`"
  }

  def handle_command(command, chat_id, args, state) do
    Logger.debug("Received command: #{command} with args: #{inspect(args)}")

    cond do
      String.starts_with?(command, "/") ->
        handle_slash_command(command, chat_id, args, state)

      !is_nil(state[:step]) ->
        handle_step_command(command, chat_id, args, state)

      true ->
        {state, nil}
    end
  end

  defp handle_slash_command("/start", chat_id, _args, state) do
    send_welcome_message(chat_id)
    {state, nil}
  end

  defp handle_slash_command("/subscribe", chat_id, [token_address, chain_id], state) do
    parsed_chain_id = String.to_integer(chain_id)

    ChatSubscriptionManager.subscribe(chat_id, %{
      token_address: token_address,
      chain_id: parsed_chain_id
    })

    {state, nil}
  end

  defp handle_slash_command("/subscribe", chat_id, _args, state) do
    TelegramClient.send_message(
      chat_id,
      "Please provide a token address and chain ID to subscribe."
    )

    {state, nil}
  end

  defp handle_slash_command("/unsubscribe", chat_id, [token_address, chain_id], state) do
    parsed_chain_id = String.to_integer(chain_id)
    ChatSubscriptionManager.unsubscribe(chat_id, token_address, parsed_chain_id)
    {state, nil}
  end

  defp handle_slash_command("/unsubscribe", chat_id, _args, state) do
    TelegramClient.send_message(
      chat_id,
      "Please provide a token address and chain ID to unsubscribe."
    )

    {state, nil}
  end

  defp handle_slash_command("/unsubscribeAll", chat_id, _args, state) do
    ChatSubscriptionManager.unsubscribe(chat_id)
    {state, nil}
  end

  defp handle_slash_command("/subscriptions", chat_id, _args, state) do
    list_subscriptions(chat_id)
    {state, nil}
  end

  defp handle_slash_command("/settings", chat_id, args, state) do
    if Enum.empty?(args) do
      message =
        "No settings provided. Use the format /settings option:value to update settings. For example, /settings min_buy_amount:100."

      TelegramClient.send_message(chat_id, message)

      {state, nil}
    else
      update_settings(chat_id, args)

      {state, nil}
    end

    if valid_settings_args?(args) do
      update_settings(chat_id, args)
      {state, nil}
    else
      message = "Invalid settings provided. Please check your configuration."
      TelegramClient.send_message(chat_id, message)
      {state, nil}
    end
  end

  defp handle_slash_command("/addToken", chat_id, _args, state) do
    state = Map.put(state, :step, :token_address)

    reply = %{chat_id: chat_id, text: "Please enter the token address:"}

    {state, reply}
  end

  defp handle_slash_command("/help", chat_id, args = ["help" | _], state) do
    send_command_help(chat_id, "/help " <> Enum.join(args, " "))
    {state, nil}
  end

  defp handle_slash_command("/help", chat_id, [command], state) when command != "help" do
    send_command_help(chat_id, "/" <> command)
    {state, nil}
  end

  defp handle_slash_command("/help", chat_id, [], state) do
    send_help_message(chat_id)
    {state, nil}
  end

  defp handle_slash_command("/addToken", chat_id, _args, state) do
    state = Map.put(state, :step, :token_address)
    reply = %{chat_id: chat_id, text: "Please enter the token address:"}
    {state, reply}
  end

  defp handle_slash_command("/feedback", chat_id, args, state) do
    feedback_message = Enum.join(args, " ")
    Logger.info("Received feedback from #{chat_id}: #{feedback_message}")
    TelegramClient.send_message(chat_id, "Thank you for your feedback!")
    {state, nil}
  end

  defp handle_slash_command(_command, chat_id, _args, state) do
    unknown_command(chat_id)
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

    TelegramClient.send_message(chat_id, message)
  end

  defp recursive_help() do
    "🤯 Are you trying to break me? Just kidding, ask away! But seriously, type /help for the command list."
  end

  defp handle_step_command(command, chat_id, _, state) do
    case state.step do
      :token_address ->
        token_address = command

        if valid_token_address?(token_address) do
          new_state = Map.put(state, :token_address, token_address) |> Map.put(:step, :chain_id)
          reply = %{chat_id: chat_id, text: "Please select the chain:"}
          {new_state, reply}
        else
          reply = %{chat_id: chat_id, text: "Invalid token address. Please try again."}
          {state, reply}
        end

      :chain_id ->
        chain_id = command

        new_state =
          Map.put(state, :chain_id, chain_id)
          |> Map.put(:step, :alert_image_url)

        reply = %{chat_id: chat_id, text: "Please enter the alert image URL:"}
        {new_state, reply}

      :alert_image_url ->
        alert_image_url = command

        new_state =
          Map.put(state, :alert_image_url, alert_image_url)
          |> Map.put(:step, :website_url)

        reply = %{chat_id: chat_id, text: "Please enter the website URL:"}
        {new_state, reply}

      :website_url ->
        website_url = command

        new_state =
          Map.put(state, :website_url, website_url)
          |> Map.put(:step, :twitter_handle)

        reply = %{chat_id: chat_id, text: "Please enter the Twitter handle:"}
        {new_state, reply}

      :twitter_handle ->
        twitter_handle = command

        new_state =
          Map.put(state, :twitter_handle, twitter_handle)
          |> Map.put(:step, :discord_link)

        reply = %{chat_id: chat_id, text: "Please enter the Discord link:"}
        {new_state, reply}

      :discord_link ->
        discord_link = command

        new_state =
          Map.put(state, :discord_link, discord_link)
          |> Map.put(:step, :telegram_link)

        reply = %{chat_id: chat_id, text: "Please enter the Telegram link:"}
        {new_state, reply}

      :telegram_link ->
        telegram_link = command

        if valid_link?(telegram_link) do
          new_state = Map.put(state, :telegram_link, telegram_link)
          finalize_token_addition(chat_id, new_state)
          {%{}, nil}
        else
          reply = %{
            chat_id: chat_id,
            text: "Invalid Telegram link provided. Please provide a valid link."
          }

          {state, reply}
        end

      _ ->
        unknown_command(chat_id)
        {state, nil}
    end
  end

  defp send_welcome_message(chat_id) do
    message = "Welcome to the Balancer Buy Bot. Type /help for more information."
    TelegramClient.send_message(chat_id, message)
  end

  defp valid_token_address?(_address) do
    # Add your validation logic here
    true
  end

  defp list_subscriptions(chat_id) do
    case ChatSubscriptionManager.list_subscriptions(chat_id) do
      [] ->
        TelegramClient.send_message(chat_id, "You are not subscribed to any tokens.")

      subscriptions when is_list(subscriptions) ->
        message = format_subscription_list(subscriptions)
        TelegramClient.send_message(chat_id, message)

      _ ->
        TelegramClient.send_message(chat_id, "Failed to fetch subscriptions.")
    end
  end

  defp update_settings(chat_id, args) do
    settings = parse_settings(args)
    ChatSubscriptionManager.update_settings(chat_id, settings)
    TelegramClient.send_message(chat_id, "Settings updated successfully.")
  end

  defp send_help_message(chat_id) do
    message = """
    *Welcome to the Balancer Buy Bot!* Here’s how you can interact with me:

    - *`/addToken`*: Start the process to add a new token for buy alerts. Follow the prompts to configure settings for the token.
    - *`/subscribe [token_address] [chain_id]`*: Subscribe to buy alerts for a specific token. Specify the token address and the chain.
    - *`/unsubscribe [token_address] [chain_id]`*: Unsubscribe from alerts for a specific token on a specified chain.
    - *`/unsubscribeAll`*: Unsubscribe from all alerts.
    - *`/subscriptions`*: View a list of all your current token subscriptions and their specific settings.
    - *`/settings [option:value]`*: Modify settings for notifications. Available options include `min_buy_amount`, `trade_size_emoji`, etc. Example: `/settings min_buy_amount:50`.
    - *`/help [command]`*: Get detailed information about a specific command. Just add the command after `/help`.

    Use these commands to stay updated on token trades and manage your alert preferences.
    """

    TelegramClient.send_message(chat_id, message)
  end

  defp unknown_command(chat_id) do
    TelegramClient.send_message(
      chat_id,
      "Unknown command. Please type /help for a list of available commands."
    )
  end

  defp finalize_token_addition(chat_id, state) do
    ChatSubscriptionManager.subscribe(chat_id, state, state.chain_id)

    confirmation_message = """
    Token added successfully with the following details:
    Token Address: #{state.token_address}
    Chain ID: #{state.chain_id}
    Alert Image URL: #{state.alert_image_url}
    Website URL: #{state.website_url}
    Twitter Handle: #{state.twitter_handle}
    Discord Link: #{state.discord_link}
    Telegram Link: #{state.telegram_link}
    """

    TelegramClient.send_message(chat_id, confirmation_message)
  end

  defp valid_link?(link) do
    link != nil and link != ""
  end

  defp parse_settings(args) do
    Enum.map(args, fn arg ->
      [key, value] = String.split(arg, ":")

      {String.to_atom(key), value}
    end)
    |> Enum.into(%{})
  end

  defp format_subscription_list(subscriptions) do
    Enum.map(subscriptions, fn %{token_address: token_address, chain_id: chain_id} ->
      "Token Address: #{token_address}, Chain ID: #{chain_id}"
    end)
    |> Enum.join("\n")
  end

  defp valid_settings_args?(args) do
    # Example validation: Ensure that certain required keys are present
    required_keys = ["min_buy_amount", "trade_size_step", "alert_image"]

    Enum.all?(required_keys, fn key ->
      Enum.any?(args, fn arg ->
        String.starts_with?(arg, key <> ":")
      end)
    end)
  end
end
