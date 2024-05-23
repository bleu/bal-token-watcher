defmodule SwapListener.CommandHandler.Main do
  @moduledoc false

  alias SwapListener.ChatSubscriptionManager
  alias SwapListener.CommandHandler.Help
  alias SwapListener.CommandHandler.Pause
  alias SwapListener.CommandHandler.Restart
  alias SwapListener.CommandHandler.Settings
  alias SwapListener.CommandHandler.Start
  alias SwapListener.CommandHandler.Subscribe
  alias SwapListener.CommandHandler.Unsubscribe
  alias SwapListener.CommandHandler.Utils
  alias SwapListener.CommandHandlerHelper

  require Logger

  @telegram_client Application.compile_env(:swap_listener, :telegram_client, SwapListener.RateLimitedTelegramClientImpl)

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

  defp handle_slash_command("/start", chat_id, args, state), do: Start.handle(chat_id, args, state)
  defp handle_slash_command("/subscribe", chat_id, args, state), do: Subscribe.handle(chat_id, args, state)
  defp handle_slash_command("/unsubscribe", chat_id, args, state), do: Unsubscribe.handle(chat_id, args, state)
  defp handle_slash_command("/unsubscribeAll", chat_id, args, state), do: Unsubscribe.handle_all(chat_id, args, state)
  defp handle_slash_command("/settings", chat_id, args, state), do: Settings.handle(chat_id, args, state)
  defp handle_slash_command("/pause", chat_id, args, state), do: Pause.handle(chat_id, args, state)
  defp handle_slash_command("/pauseAll", chat_id, args, state), do: Pause.handle_all(chat_id, args, state)
  defp handle_slash_command("/restart", chat_id, args, state), do: Restart.handle(chat_id, args, state)
  defp handle_slash_command("/restartAll", chat_id, args, state), do: Restart.handle_all(chat_id, args, state)
  defp handle_slash_command("/help", chat_id, args, state), do: Help.handle(chat_id, args, state)

  defp handle_slash_command("/subscriptions", chat_id, _args, state) do
    list_subscriptions(chat_id)
    {state, nil}
  end

  defp handle_slash_command("/addToken", chat_id, _args, state) do
    state = Map.put(state, :step, :chain_id)

    reply = %{chat_id: chat_id, text: "Please select the chain:#{CommandHandlerHelper.available_chains_text()}"}

    {state, reply}
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

          token_sym = Utils.get_token_sym(token_address, state[:chain_id])
          confirmation_message = "You have selected the token: #{token_sym} (#{token_address})."

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

  defp list_subscriptions(chat_id) do
    case ChatSubscriptionManager.list_subscriptions(chat_id) do
      [] ->
        @telegram_client.send_message(chat_id, "You are not subscribed to any tokens.")

      subscriptions when is_list(subscriptions) ->
        message = Utils.format_subscription_table(subscriptions)
        @telegram_client.send_message(chat_id, message)

      _ ->
        @telegram_client.send_message(chat_id, "Failed to fetch subscriptions.")
    end
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

  defp valid_token_address?(address) do
    is_binary(address) and address != "" and Regex.match?(~r/^0x[a-fA-F0-9]{40}$/, address)
  end

  defp valid_link?(link), do: link != nil and link != ""
end
