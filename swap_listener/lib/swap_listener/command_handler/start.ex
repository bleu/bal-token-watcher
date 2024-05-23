defmodule SwapListener.CommandHandler.Start do
  @moduledoc false
  alias SwapListener.TelegramClientImpl

  @telegram_client Application.get_env(:swap_listener, :telegram_client, SwapListener.TelegramClientImpl)

  def handle(chat_id, _args, state) do
    send_welcome_message(chat_id)
    {state, nil}
  end

  defp send_welcome_message(chat_id) do
    message = "Welcome to the Balancer Buy Bot. Type /help for more information."
    @telegram_client.send_message(chat_id, message)
  end
end
