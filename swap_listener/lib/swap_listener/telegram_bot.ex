defmodule SwapListener.TelegramBot do
  @moduledoc false
  use Telegram.ChatBot

  alias SwapListener.CommandHandler

  require Logger

  @telegram_client Application.get_env(:swap_listener, :telegram_client, SwapListener.TelegramClientImpl)

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

  defp handle_message(%{"text" => text, "chat" => %{"id" => chat_id}}, state) do
    Logger.debug("Received message: #{text} from chat: #{chat_id}")
    [command | args] = String.split(text)

    CommandHandler.Main.handle_command(command, chat_id, args, state)
  end
end
