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
    request_id = 4 |> :crypto.strong_rand_bytes() |> :binary.decode_unsigned()

    if request_id > 2_147_483_647 do
      ^request_id = request_id - 4_294_967_296
    end

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

  def handle_step(:chat_selection, command, chat_id, user_id, state) do
    Logger.debug("Received chat selection: #{inspect(command)}")
    subscription_chat_id = command

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
      new_state = state |> Map.put(:token_address, token_address) |> Map.put(:step, :alert_image_url)

      token_sym = Utils.get_token_sym(token_address, state[:chain_id])
      confirmation_message = "You have selected the token: #{token_sym} (#{token_address})."

      reply = %{chat_id: chat_id, text: "#{confirmation_message}\nPlease enter the alert image URL:"}
      {new_state, reply}
    else
      reply = %{chat_id: chat_id, text: "Invalid token address. Please try again."}
      {state, reply}
    end
  end

  def handle_step(:alert_image_url, command, chat_id, _user_id, state) do
    alert_image_url = command

    new_state =
      state
      |> Map.put(:alert_image_url, alert_image_url)
      |> Map.put(:step, :website_url)

    reply = %{chat_id: chat_id, text: "Please enter the website URL:"}
    {new_state, reply}
  end

  def handle_step(:website_url, command, chat_id, _user_id, state) do
    website_url = command

    new_state =
      state
      |> Map.put(:website_url, website_url)
      |> Map.put(:step, :twitter_handle)

    reply = %{chat_id: chat_id, text: "Please enter the Twitter handle:"}
    {new_state, reply}
  end

  def handle_step(:twitter_handle, command, chat_id, _user_id, state) do
    twitter_handle = command

    new_state =
      state
      |> Map.put(:twitter_handle, twitter_handle)
      |> Map.put(:step, :discord_link)

    reply = %{chat_id: chat_id, text: "Please enter the Discord link:"}
    {new_state, reply}
  end

  def handle_step(:discord_link, command, chat_id, _user_id, state) do
    discord_link = command

    new_state =
      state
      |> Map.put(:discord_link, discord_link)
      |> Map.put(:step, :telegram_link)

    reply = %{chat_id: chat_id, text: "Please enter the Telegram link:"}
    {new_state, reply}
  end

  def handle_step(:telegram_link, command, chat_id, _user_id, state) do
    telegram_link = command

    if valid_url?(telegram_link) do
      new_state =
        state
        |> Map.put(:telegram_link, telegram_link)
        |> Map.put(:step, :trade_size_emoji)

      reply = %{chat_id: chat_id, text: "Please enter the trade size emoji:"}
      {new_state, reply}
    else
      reply = %{
        chat_id: chat_id,
        text: "Invalid Telegram link provided. Please provide a valid link."
      }

      {state, reply}
    end
  end

  def handle_step(:trade_size_emoji, command, chat_id, _user_id, state) do
    trade_size_emoji = command

    new_state =
      state
      |> Map.put(:trade_size_emoji, trade_size_emoji)
      |> Map.put(:step, :trade_size_step)

    reply = %{chat_id: chat_id, text: "Please enter the trade size step:"}
    {new_state, reply}
  end

  def handle_step(:trade_size_step, command, chat_id, _user_id, state) do
    trade_size_step = command

    new_state =
      state
      |> Map.put(:trade_size_step, trade_size_step)
      |> Map.put(:step, :min_buy_amount)

    reply = %{chat_id: chat_id, text: "Please enter the minimum buy amount:"}
    {new_state, reply}
  end

  def handle_step(:min_buy_amount, command, chat_id, user_id, state) do
    min_buy_amount = command

    new_state = Map.put(state, :min_buy_amount, min_buy_amount)
    finalize_token_addition(chat_id, user_id, new_state)
    {%{}, nil}
  end

  defp finalize_token_addition(chat_id, user_id, state) do
    ChatSubscriptionManager.subscribe(chat_id, user_id, state)

    confirmation_message = """
    Token added successfully with the following details:
    #{Utils.format_subscription_settings(state)}
    """

    @telegram_client.send_message(chat_id, confirmation_message)
  end

  defp valid_token_address?(address) do
    is_binary(address) and address != "" and Regex.match?(~r/^0x[a-fA-F0-9]{40}$/, address)
  end

  defp valid_url?(url) do
    case :httpc.request(:head, {to_charlist(url), []}, [], []) do
      {:ok, _response} -> true
      {:error, _reason} -> false
    end
  end
end
