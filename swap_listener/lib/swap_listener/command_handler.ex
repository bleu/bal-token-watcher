defmodule SwapListener.CommandHandler do
  @moduledoc false
  alias SwapListener.ChatSubscriptionManager

  require Logger

  @telegram_client Application.get_env(:swap_listener, :telegram_client, SwapListener.TelegramClientImpl)

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
    "/pauseAll" => "*Pause All Token Alerts.*",
    "/addToken" => """
    *Add a New Token for Buy Alerts*
    `/addToken` - Begin the process to add a new token. You will be prompted to enter the chain ID, token address, and configure settings.
    """,
    "/help" =>
      "You're really into this, aren't you? 😄 Here’s a help for your help: just keep adding 'help' to go deeper. Example: `/help help help`"
  }

  @available_chains """
  *Available Chains:*
  - Ethereum (1)
  - Polygon (137)
  - Arbitrum (42161)
  - Optimism (10)
  - Gnosis Chain (100)
  """

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

  defp handle_slash_command("/pause", chat_id, [token_address, chain_id], state) do
    parsed_chain_id = String.to_integer(chain_id)
    ChatSubscriptionManager.pause(chat_id, token_address, parsed_chain_id)
    {state, nil}
  end

  defp handle_slash_command("/pause", chat_id, _args, state) do
    @telegram_client.send_message(chat_id, "Please provide a token address and chain ID to pause.")
    {state, nil}
  end

  defp handle_slash_command("/pauseAll", chat_id, _args, state) do
    ChatSubscriptionManager.pause_all(chat_id)
    {state, nil}
  end

  defp handle_slash_command("/settings", chat_id, [token_address, chain_id | rest], state) do
    if Enum.empty?(rest) do
      message =
        "No settings provided. Use the format /settings token_address chain_id option:value to update settings. For example, /settings 0xTokenAddress 1 min_buy_amount:100."

      @telegram_client.send_message(chat_id, message)
      {state, nil}
    else
      parsed_chain_id = String.to_integer(chain_id)
      update_subscription_settings(chat_id, token_address, parsed_chain_id, rest)
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
    @telegram_client.send_message(
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
    @telegram_client.send_message(
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

  defp handle_slash_command("/addToken", chat_id, _args, state) do
    state = Map.put(state, :step, :chain_id)

    reply = %{chat_id: chat_id, text: "Please select the chain:#{@available_chains}"}

    {state, reply}
  end

  defp handle_slash_command("/help", chat_id, ["help" | _] = args, state) do
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

  defp handle_slash_command("/feedback", chat_id, args, state) do
    feedback_message = Enum.join(args, " ")
    Logger.info("Received feedback from #{chat_id}: #{feedback_message}")
    @telegram_client.send_message(chat_id, "Thank you for your feedback!")
    {state, nil}
  end

  defp handle_slash_command(_command, chat_id, _args, state) do
    unknown_command(chat_id)
    {state, nil}
  end

  defp update_subscription_settings(chat_id, token_address, chain_id, args) do
    case parse_settings(args) do
      {:ok, settings} ->
        ChatSubscriptionManager.update_subscription_settings(chat_id, token_address, chain_id, settings)

        @telegram_client.send_message(
          chat_id,
          "Settings updated successfully for #{token_address} on chain #{chain_id}. New settings: #{inspect(settings)}"
        )

      {:error, reason} ->
        @telegram_client.send_message(chat_id, "Failed to update settings: #{reason}")
    end
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

  defp handle_step_command(command, chat_id, _, state) do
    case state[:step] do
      :chain_id ->
        chain_id = command

        new_state =
          state
          |> Map.put(:chain_id, chain_id)
          |> Map.put(:step, :token_address)

        reply = %{chat_id: chat_id, text: "Please enter the token address:"}
        {new_state, reply}

      :token_address ->
        token_address = command

        if valid_token_address?(token_address) do
          new_state = state |> Map.put(:token_address, token_address) |> Map.put(:step, :alert_image_url)

          token_name = get_token_name(token_address)
          confirmation_message = "You have selected the token: #{token_name} (#{token_address})."

          reply = %{chat_id: chat_id, text: "#{confirmation_message}\nPlease enter the alert image URL:"}
          {new_state, reply}
        else
          reply = %{chat_id: chat_id, text: "Invalid token address. Please try again."}
          {state, reply}
        end

      :alert_image_url ->
        alert_image_url = command

        new_state =
          state
          |> Map.put(:alert_image_url, alert_image_url)
          |> Map.put(:step, :website_url)

        reply = %{chat_id: chat_id, text: "Please enter the website URL:"}
        {new_state, reply}

      :website_url ->
        website_url = command

        new_state =
          state
          |> Map.put(:website_url, website_url)
          |> Map.put(:step, :twitter_handle)

        reply = %{chat_id: chat_id, text: "Please enter the Twitter handle:"}
        {new_state, reply}

      :twitter_handle ->
        twitter_handle = command

        new_state =
          state
          |> Map.put(:twitter_handle, twitter_handle)
          |> Map.put(:step, :discord_link)

        reply = %{chat_id: chat_id, text: "Please enter the Discord link:"}
        {new_state, reply}

      :discord_link ->
        discord_link = command

        new_state =
          state
          |> Map.put(:discord_link, discord_link)
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
    @telegram_client.send_message(chat_id, message)
  end

  defp valid_token_address?(address) do
    is_binary(address) and address != "" and Regex.match?(~r/^0x[a-fA-F0-9]{40}$/, address)
  end

  defp list_subscriptions(chat_id) do
    case ChatSubscriptionManager.list_subscriptions(chat_id) do
      [] ->
        @telegram_client.send_message(chat_id, "You are not subscribed to any tokens.")

      subscriptions when is_list(subscriptions) ->
        message = format_subscription_list(subscriptions)
        @telegram_client.send_message(chat_id, message)

      _ ->
        @telegram_client.send_message(chat_id, "Failed to fetch subscriptions.")
    end
  end

  defp parse_settings(args) do
    if valid_settings_args?(args) do
      settings =
        Enum.map(args, fn arg ->
          case String.split(arg, ":") do
            [key, value] -> {:ok, {String.to_atom(key), value}}
            _ -> {:error, "Invalid format for #{arg}"}
          end
        end)

      if Enum.any?(settings, &match?({:error, _}, &1)) do
        {:error, Enum.filter(settings, &match?({:error, _}, &1))}
      else
        {:ok, Enum.map(settings, fn {:ok, setting} -> setting end)}
      end
    else
      {:error, "Invalid settings format. Please provide settings in the format option:value."}
    end
  end

  defp valid_settings_args?(args) do
    required_keys = ["min_buy_amount", "trade_size_step", "alert_image_url"]

    Enum.all?(required_keys, fn key ->
      Enum.any?(args, fn arg ->
        String.starts_with?(arg, key <> ":")
      end)
    end)
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

    @telegram_client.send_message(chat_id, message)
  end

  defp unknown_command(chat_id) do
    @telegram_client.send_message(
      chat_id,
      "Unknown command. Please type /help for a list of available commands."
    )
  end

  defp finalize_token_addition(chat_id, state) do
    ChatSubscriptionManager.subscribe(chat_id, state)

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

    @telegram_client.send_message(chat_id, confirmation_message)
  end

  defp valid_link?(link) do
    link != nil and link != ""
  end

  defp format_subscription_list(subscriptions) do
    Enum.map_join(subscriptions, "\n", fn %{token_address: token_address, chain_id: chain_id} ->
      "Token Address: #{token_address}, Chain ID: #{chain_id}"
    end)
  end

  defp get_token_name(_token_address) do
    # Implement the logic to get the token name based on the address
    # Replace this with actual logic
    "Sample Token"
  end
end
