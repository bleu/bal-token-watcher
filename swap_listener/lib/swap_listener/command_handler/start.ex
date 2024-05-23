defmodule SwapListener.CommandHandler.Start do
  @moduledoc false

  @telegram_client Application.compile_env(:swap_listener, :telegram_client, SwapListener.RateLimitedTelegramClientImpl)

  def handle(chat_id, _args, state) do
    send_welcome_message(chat_id)
    {state, nil}
  end

  defp send_welcome_message(chat_id) do
    message = "Welcome to the Balancer Buy Bot. Type /help for more information."
    @telegram_client.send_message(chat_id, message)
  end
end
