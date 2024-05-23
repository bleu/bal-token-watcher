defmodule SwapListener.TelegramBot do
  @moduledoc false
  use Telegram.ChatBot

  alias SwapListener.AllowList
  alias SwapListener.CommandHandler

  require Logger

  @telegram_client Application.compile_env(:swap_listener, :telegram_client, SwapListener.RateLimitedTelegramClientImpl)

  @session_ttl 60 * 1_000

  @impl Telegram.ChatBot
  def init(_chat) do
    state = %{
      step: nil,
      token_address: nil,
      chain_id: nil,
      alert_image_url: nil,
      website_url: nil,
      twitter_handle: nil,
      discord_link: nil,
      telegram_link: nil
    }

    {:ok, state, @session_ttl}
  end

  @impl Telegram.ChatBot
  def handle_update(update, _context, state) do
    Logger.debug("Received update: #{inspect(update)}. State: #{inspect(state)}")

    {new_state, reply} =
      case update do
        %{"message" => message} ->
          handle_message(message, state)

        %{"edited_message" => message} ->
          handle_message(message, state)

        _ ->
          Logger.info("Unhandled message type")
          {state, nil}
      end

    if reply do
      @telegram_client.send_message(reply.chat_id, reply.text)
    end

    Logger.debug("New state: #{inspect(new_state)}")

    state = new_state

    {:ok, state, @session_ttl}
  end

  defp handle_message(
         %{
           "new_chat_member" => %{"username" => _username} = new_member,
           "chat" => %{"id" => chat_id},
           "from" => %{"username" => from_username}
         },
         state
       ) do
    Logger.debug("New chat member: #{inspect(new_member)} added by: #{from_username} in chat: #{chat_id}")

    if AllowList.allowed?(from_username) do
      @telegram_client.send_message(chat_id, "Hello #{new_member["first_name"]}!")
      Logger.info("Sent hello message to #{new_member["username"]}")
    else
      Logger.warning("User #{from_username} is not allowed to add members")
      # TODO: leave group
    end

    {state, nil}
  end

  defp handle_message(%{"text" => text, "chat" => %{"id" => chat_id}}, state) do
    Logger.debug("Received message: #{text} from chat: #{chat_id}")
    [command | args] = String.split(text)

    CommandHandler.Main.handle_command(command, chat_id, args, state)
  end

  defp handle_message(message, state) do
    Logger.info("Unhandled message received: #{inspect(message)}")
    {state, nil}
  end
end
