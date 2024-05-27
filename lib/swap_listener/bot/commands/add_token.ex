defmodule SwapListener.Bot.Commands.AddToken do
  @moduledoc false
  alias SwapListener.Bot.Commands.Utils
  alias SwapListener.ChatSubscription.ChatSubscriptionManager
  alias SwapListener.Common.BlockchainConfig
  alias SwapListener.Telegram.TelegramClientImpl

  require Logger

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  def handle(chat_id, _user_id, _args, state) do
    request_id = generate_request_id()

    reply_markup = %{
      keyboard: [
        [
          %{
            text: "Select Group",
            request_chat: %{
              request_id: request_id,
              chat_is_channel: false,
              bot_is_member: true
            }
          }
        ]
      ],
      one_time_keyboard: true
    }

    reply = %{
      chat_id: chat_id,
      text: "Please select the group where you want to add the token subscription:",
      reply_markup: reply_markup
    }

    new_state = Map.put(state, :step, :chat_selection)

    {new_state, reply}
  end

  defp generate_request_id do
    request_id = 4 |> :crypto.strong_rand_bytes() |> :binary.decode_unsigned()
    normalize_request_id(request_id)
  end

  defp normalize_request_id(request_id) when request_id > 2_147_483_647 do
    request_id - 4_294_967_296
  end

  defp normalize_request_id(request_id), do: request_id

  defp ensure_user_is_chat_admin(chat_id, user_id) do
    case TelegramClientImpl.get_chat_member(chat_id, user_id) do
      {:ok, %{"status" => "creator"}} ->
        :ok

      {:ok, %{"status" => "administrator"}} ->
        :ok

      {:ok, %{"status" => "member"}} ->
        reply = %{chat_id: user_id, text: "You must be an admin or the group owner to add a token subscription."}
        {:error, reply}

      {:error, reason} ->
        Logger.error("Failed to fetch chat member status: #{inspect(reason)}")
        reply = %{chat_id: user_id, text: "Failed to fetch chat member status. Please try again."}
        {:error, reply}

      _ ->
        Logger.error("Invalid chat member status")
        reply = %{chat_id: user_id, text: "Invalid chat member status. Please try again."}
        {:error, reply}
    end
  end

  def handle_step(:chat_selection, command, chat_id, user_id, state) do
    Logger.debug("Received chat selection: #{inspect(command)}")
    subscription_chat_id = command

    case ensure_user_is_chat_admin(subscription_chat_id, user_id) do
      :ok ->
        handle_chat_selection(subscription_chat_id, chat_id, user_id, state)

      {:error, reply} ->
        {state, reply}
    end
  end

  def handle_chat_selection(subscription_chat_id, chat_id, user_id, state) do
    case TelegramClientImpl.get_chat(subscription_chat_id) do
      {:ok, %{"title" => chat_title}} ->
        new_state =
          state
          |> Map.put(:chat_id, subscription_chat_id)
          |> Map.put(:chat_title, chat_title)
          |> Map.put(:creator_id, user_id)
          |> Map.put(:step, :chain_id)

        chains = BlockchainConfig.chain_name_map()

        buttons =
          for {chain_id, _} <- chains, do: [%{text: BlockchainConfig.get_chain_label(chain_id), callback_data: chain_id}]

        reply_markup = %{inline_keyboard: buttons}

        reply = %{
          chat_id: chat_id,
          text: "Please select the chain:",
          reply_markup: reply_markup
        }

        {new_state, reply}

      {:error, reason} ->
        Logger.error("Failed to fetch chat title and creator ID: #{inspect(reason)}")
        reply = %{chat_id: chat_id, text: "Failed to fetch chat title and creator ID. Please try again."}
        {state, reply}

      _ ->
        Logger.error("Invalid chat ID: #{subscription_chat_id}")
        reply = %{chat_id: chat_id, text: "Invalid chat ID. Please try again."}
        {state, reply}
    end
  end

  def handle_step(:chain_id, command, chat_id, _user_id, state) do
    chain_id = String.to_integer(command)

    new_state =
      state
      |> Map.put(:chain_id, chain_id)
      |> Map.put(:step, :token_address)

    reply = %{chat_id: chat_id, text: "Please enter the token address:"}
    {new_state, reply}
  end

  def handle_step(:token_address, command, chat_id, _user_id, state) do
    token_address = command

    if valid_token_address?(token_address) do
      new_state = Map.put(state, :token_address, token_address)

      token_sym = Utils.get_token_sym(token_address, state[:chain_id])

      confirmation_message =
        "You have selected the token: #{token_sym} (#{token_address}). Token subscription has been added."

      reply = %{chat_id: chat_id, text: confirmation_message}
      finalize_token_addition(chat_id, new_state)
      {new_state, reply}
    else
      reply = %{chat_id: chat_id, text: "Invalid token address. Please try again."}
      {state, reply}
    end
  end

  defp finalize_token_addition(chat_id, state) do
    subscription = ChatSubscriptionManager.subscribe(chat_id, state[:creator_id], state)

    confirmation_message = """
    Token added successfully with the following details:
    #{Utils.format_subscription_settings(subscription)}
    """

    @telegram_client.send_message(chat_id, confirmation_message)
  end

  defp valid_token_address?(address) do
    is_binary(address) and address != "" and Regex.match?(~r/^0x[a-fA-F0-9]{40}$/, address)
  end
end
