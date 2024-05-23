defmodule SwapListener.CommandHandler.Restart do
  @moduledoc false
  alias SwapListener.ChatSubscriptionManager
  alias SwapListener.TelegramClientImpl

  @telegram_client Application.get_env(:swap_listener, :telegram_client, SwapListener.TelegramClientImpl)

  def handle(chat_id, [token_address, chain_id], state) do
    parsed_chain_id = String.to_integer(chain_id)
    ChatSubscriptionManager.restart(chat_id, token_address, parsed_chain_id)
    @telegram_client.send_message(chat_id, "Alerts for #{token_address} on chain #{parsed_chain_id} have been restarted.")
    {state, nil}
  end

  def handle(chat_id, _args, state) do
    @telegram_client.send_message(chat_id, "Please provide a token address and chain ID to restart.")
    {state, nil}
  end

  def handle_all(chat_id, _args, state) do
    ChatSubscriptionManager.restart_all(chat_id)
    @telegram_client.send_message(chat_id, "All paused alerts have been restarted.")
    {state, nil}
  end
end
