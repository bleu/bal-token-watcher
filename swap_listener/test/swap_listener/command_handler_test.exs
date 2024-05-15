# test/swap_listener/command_handler_test.exs
defmodule SwapListener.CommandHandlerTest do
  use SwapListener.DataCase, async: true
  alias SwapListener.CommandHandler
  alias SwapListener.ChatSubscriptionManager
  alias SwapListener.TelegramClient

  setup do
    {:ok, _} = start_supervised(SwapListener.ChatSubscriptionManager)
    :ok
  end

  test "handle_command/3 handles /start command" do
    chat_id = 123
    assert :ok == CommandHandler.handle_command("/start", chat_id, [])
  end

  test "handle_command/3 handles /subscribe command" do
    chat_id = 123
    token_address = "0xTokenAddress"
    chain_id = "1"

    assert :ok == CommandHandler.handle_command("/subscribe", chat_id, [token_address, chain_id])

    assert [
             %{
               chat_id: ^chat_id,
               token_address: ^token_address,
               chain_id: ^String.to_integer(chain_id)
             }
           ] =
             ChatSubscriptionManager.list_subscriptions(chat_id)
  end

  test "handle_command/3 handles /unsubscribe command" do
    chat_id = 123
    token_address = "0xTokenAddress"
    chain_id = "1"

    ChatSubscriptionManager.subscribe(chat_id, token_address, String.to_integer(chain_id))

    assert :ok ==
             CommandHandler.handle_command("/unsubscribe", chat_id, [token_address, chain_id])

    assert [] = ChatSubscriptionManager.list_subscriptions(chat_id)
  end

  test "handle_command/3 handles /unsubscribe_all command" do
    chat_id = 123
    token_address1 = "0xTokenAddress1"
    token_address2 = "0xTokenAddress2"
    chain_id = "1"

    ChatSubscriptionManager.subscribe(chat_id, token_address1, String.to_integer(chain_id))
    ChatSubscriptionManager.subscribe(chat_id, token_address2, String.to_integer(chain_id))
    assert :ok == CommandHandler.handle_command("/unsubscribe_all", chat_id, [])
    assert [] = ChatSubscriptionManager.list_subscriptions(chat_id)
  end

  test "handle_command/3 handles /subscriptions command" do
    chat_id = 123
    token_address1 = "0xTokenAddress1"
    token_address2 = "0xTokenAddress2"
    chain_id = "1"

    ChatSubscriptionManager.subscribe(chat_id, token_address1, String.to_integer(chain_id))
    ChatSubscriptionManager.subscribe(chat_id, token_address2, String.to_integer(chain_id))
    assert :ok == CommandHandler.handle_command("/subscriptions", chat_id, [])
  end
end
