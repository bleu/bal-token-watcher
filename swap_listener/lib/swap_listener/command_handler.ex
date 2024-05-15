defmodule SwapListener.CommandHandler do
  alias SwapListener.{ChatSubscriptionManager, TelegramClient}
  require Logger

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
    ChatSubscriptionManager.subscribe(chat_id, token_address, parsed_chain_id)
    {state, nil}
  end

  defp handle_slash_command("/unsubscribe", chat_id, [token_address, chain_id], state) do
    parsed_chain_id = String.to_integer(chain_id)
    ChatSubscriptionManager.unsubscribe(chat_id, token_address, parsed_chain_id)
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
    update_settings(chat_id, args)
    {state, nil}
  end

  defp handle_slash_command("/help", chat_id, _args, state) do
    send_help_message(chat_id)
    {state, nil}
  end

  defp handle_slash_command("/addToken", chat_id, _args, state) do
    state = Map.put(state, :step, :token_address)
    reply = %{chat_id: chat_id, text: "Please enter the token address:"}
    {state, reply}
  end

  defp handle_slash_command(_command, chat_id, _args, state) do
    unknown_command(chat_id)
    {state, nil}
  end

  defp handle_step_command(command, chat_id, args, state) do
    case state.step do
      :token_address ->
        token_address = command

        new_state =
          Map.put(state, :token_address, token_address)
          |> Map.put(:step, :chain_id)

        reply = %{chat_id: chat_id, text: "Please select the chain:"}
        {new_state, reply}

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

        if true do
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

  # Helper functions

  defp send_welcome_message(chat_id) do
    message = "Welcome to the Balancer Buy Bot. Type /help for more information."
    TelegramClient.send_message(chat_id, message)
  end

  defp list_subscriptions(chat_id) do
    case ChatSubscriptionManager.list_subscriptions(chat_id) do
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
    Welcome to the Balancer Buy Bot! Here are the commands you can use:

    /subscribe [token_address] [chain_id] - Subscribe to buy alerts for a specific token.
    /unsubscribe [token_address] [chain_id] - Unsubscribe from alerts for a specific token.
    /unsubscribeAll - Unsubscribe from all token alerts.
    /subscriptions - List your current subscriptions.
    /settings [option:value] - Update your bot settings (e.g., minimum buy amount, alert image, social links).
    /addToken - Add a new token for buy alerts.
    /help - Display this help message.

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
    ChatSubscriptionManager.subscribe(chat_id, state.token_address, state.chain_id)

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
end
