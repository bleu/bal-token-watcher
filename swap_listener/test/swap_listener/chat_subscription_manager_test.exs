# test/swap_listener/chat_subscription_manager_test.exs
defmodule SwapListener.ChatSubscriptionManagerTest do
  use SwapListener.DataCase, async: true
  alias SwapListener.ChatSubscriptionManager
  alias SwapListener.Repo
  alias SwapListener.ChatSubscription

  setup do
    {:ok, _} = start_supervised(SwapListener.ChatSubscriptionManager)
    :ok
  end

  describe "subscribe/3" do
    test "successfully subscribes to a new token" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1

      assert :ok == ChatSubscriptionManager.subscribe(chat_id, token_address, chain_id)

      assert [
               %ChatSubscription{
                 chat_id: ^chat_id,
                 token_address: ^token_address,
                 chain_id: ^chain_id
               }
             ] =
               Repo.all(ChatSubscription)
    end

    test "does not subscribe to the same token twice" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1

      ChatSubscriptionManager.subscribe(chat_id, token_address, chain_id)

      assert {:error, _changeset} =
               ChatSubscriptionManager.subscribe(chat_id, token_address, chain_id)

      assert 1 == length(Repo.all(ChatSubscription))
    end
  end

  describe "unsubscribe/3" do
    test "successfully unsubscribes from a token" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1

      ChatSubscriptionManager.subscribe(chat_id, token_address, chain_id)
      assert :ok == ChatSubscriptionManager.unsubscribe(chat_id, token_address, chain_id)

      assert [] = Repo.all(ChatSubscription)
    end
  end

  describe "unsubscribe/1" do
    test "successfully unsubscribes from all tokens" do
      chat_id = 123
      token_address1 = "0xTokenAddress1"
      token_address2 = "0xTokenAddress2"
      chain_id = 1

      ChatSubscriptionManager.subscribe(chat_id, token_address1, chain_id)
      ChatSubscriptionManager.subscribe(chat_id, token_address2, chain_id)
      assert :ok == ChatSubscriptionManager.unsubscribe(chat_id)

      assert [] = Repo.all(ChatSubscription)
    end
  end

  describe "list_subscriptions/1" do
    test "lists all subscriptions for a chat" do
      chat_id = 123
      token_address1 = "0xTokenAddress1"
      token_address2 = "0xTokenAddress2"
      chain_id = 1

      ChatSubscriptionManager.subscribe(chat_id, token_address1, chain_id)
      ChatSubscriptionManager.subscribe(chat_id, token_address2, chain_id)

      assert [
               %{token_address: ^token_address1, chain_id: ^chain_id},
               %{token_address: ^token_address2, chain_id: ^chain_id}
             ] =
               ChatSubscriptionManager.list_subscriptions(chat_id)
    end
  end
end
