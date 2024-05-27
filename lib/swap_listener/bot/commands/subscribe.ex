defmodule SwapListener.Bot.Commands.Subscribe do
  @moduledoc false
  alias SwapListener.ChatSubscription.ChatSubscriptionManager

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  def handle(chat_id, _user_id, [token_address, chain_id], state) do
    parsed_chain_id = String.to_integer(chain_id)
    user_id = state[:creator_id]

    ChatSubscriptionManager.subscribe(chat_id, user_id, %{
      token_address: token_address,
      chain_id: parsed_chain_id
    })

    {state, nil}
  end

  def handle(chat_id, _user_id, _args, state) do
    @telegram_client.send_message(
      chat_id,
      "Please provide a token address and chain ID to subscribe."
    )

    {state, nil}
  end
end
