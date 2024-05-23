defmodule SwapListener.ChatSubscriptionManagerTest do
  use SwapListener.DataCase, async: true

  import Mox

  alias SwapListener.ChatSubscription
  alias SwapListener.ChatSubscriptionManager
  alias SwapListener.Repo

  setup :verify_on_exit!

  setup do
    # This will be handled by DataCase setup, so remove the manual checkout and mode setting
    :ok
  end

  describe "subscribe/2" do
    test "subscribes a chat to a token when not already subscribed" do
      chat_id = 123

      state = %{
        token_address: "0xTokenAddress",
        chain_id: 1,
        trade_size_step: 0.1,
        trade_size_emoji: "💰",
        min_buy_amount: 0.1,
        alert_image_url: "http://example.com/alert.png",
        website_url: "http://example.com",
        twitter_handle: "@example",
        discord_link: "http://example.com/discord",
        telegram_link: "http://example.com/telegram"
      }

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.subscribe(chat_id, state)

      subscription = Repo.one(ChatSubscription)
      assert subscription.chat_id == chat_id
      assert subscription.token_address == state.token_address
      assert subscription.chain_id == state.chain_id
    end

    test "does not subscribe if already subscribed" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1

      Repo.insert!(%ChatSubscription{
        chat_id: chat_id,
        token_address: token_address,
        chain_id: chain_id,
        trade_size_step: Decimal.new("0.1"),
        trade_size_emoji: "💰",
        min_buy_amount: Decimal.new("0.1"),
        alert_image_url: "http://example.com/alert.png",
        website_url: "http://example.com",
        twitter_handle: "@example",
        discord_link: "http://example.com/discord",
        telegram_link: "http://example.com/telegram",
        paused: false
      })

      state = %{
        token_address: token_address,
        chain_id: chain_id
      }

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.subscribe(chat_id, state)

      subscriptions = Repo.all(ChatSubscription)
      assert length(subscriptions) == 1
    end
  end

  describe "unsubscribe/3" do
    test "unsubscribes a chat from a specific token" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1

      Repo.insert!(%ChatSubscription{
        chat_id: chat_id,
        token_address: token_address,
        chain_id: chain_id,
        trade_size_step: Decimal.new("0.1"),
        trade_size_emoji: "💰",
        min_buy_amount: Decimal.new("0.1"),
        alert_image_url: "http://example.com/alert.png",
        website_url: "http://example.com",
        twitter_handle: "@example",
        discord_link: "http://example.com/discord",
        telegram_link: "http://example.com/telegram",
        paused: false
      })

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.unsubscribe(chat_id, token_address, chain_id)

      subscriptions = Repo.all(ChatSubscription)
      assert Enum.empty?(subscriptions)
    end

    test "sends a message when no subscriptions found" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.unsubscribe(chat_id, token_address, chain_id)

      subscriptions = Repo.all(ChatSubscription)
      assert Enum.empty?(subscriptions)
    end
  end

  describe "unsubscribe/1" do
    test "unsubscribes a chat from all tokens" do
      chat_id = 123

      Repo.insert!(%ChatSubscription{
        chat_id: chat_id,
        token_address: "0xTokenAddress1",
        chain_id: 1,
        trade_size_step: Decimal.new("0.1"),
        trade_size_emoji: "💰",
        min_buy_amount: Decimal.new("0.1"),
        alert_image_url: "http://example.com/alert1.png",
        website_url: "http://example.com",
        twitter_handle: "@example",
        discord_link: "http://example.com/discord",
        telegram_link: "http://example.com/telegram",
        paused: false
      })

      Repo.insert!(%ChatSubscription{
        chat_id: chat_id,
        token_address: "0xTokenAddress2",
        chain_id: 1,
        trade_size_step: Decimal.new("0.1"),
        trade_size_emoji: "💰",
        min_buy_amount: Decimal.new("0.1"),
        alert_image_url: "http://example.com/alert2.png",
        website_url: "http://example.com",
        twitter_handle: "@example",
        discord_link: "http://example.com/discord",
        telegram_link: "http://example.com/telegram",
        paused: false
      })

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.unsubscribe(chat_id)

      subscriptions = Repo.all(ChatSubscription)
      assert Enum.empty?(subscriptions)
    end

    test "sends a message when no subscriptions found" do
      chat_id = 123

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.unsubscribe(chat_id)

      subscriptions = Repo.all(ChatSubscription)
      assert Enum.empty?(subscriptions)
    end
  end

  describe "update_subscription_settings/4" do
    test "updates subscription settings when subscription exists" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1

      subscription =
        Repo.insert!(%ChatSubscription{
          chat_id: chat_id,
          token_address: token_address,
          chain_id: chain_id,
          trade_size_step: Decimal.new("0.1"),
          trade_size_emoji: "💰",
          min_buy_amount: Decimal.new("0.1"),
          alert_image_url: "http://example.com/alert.png",
          website_url: "http://example.com",
          twitter_handle: "@example",
          discord_link: "http://example.com/discord",
          telegram_link: "http://example.com/telegram",
          paused: false
        })

      settings = %{min_buy_amount: 1.0}

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.update_subscription_settings(chat_id, token_address, chain_id, settings)

      updated_subscription = Repo.get(ChatSubscription, subscription.id)
      assert Decimal.eq?(updated_subscription.min_buy_amount, Decimal.new("1.0"))
    end

    test "sends a message when subscription does not exist" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1
      settings = %{min_buy_amount: 1.0}

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.update_subscription_settings(chat_id, token_address, chain_id, settings)

      subscription = Repo.one(ChatSubscription)
      assert is_nil(subscription)
    end
  end

  describe "pause/3" do
    test "pauses alerts for a specific token" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1

      subscription =
        Repo.insert!(%ChatSubscription{
          chat_id: chat_id,
          token_address: token_address,
          chain_id: chain_id,
          trade_size_step: Decimal.new("0.1"),
          trade_size_emoji: "💰",
          min_buy_amount: Decimal.new("0.1"),
          alert_image_url: "http://example.com/alert.png",
          website_url: "http://example.com",
          twitter_handle: "@example",
          discord_link: "http://example.com/discord",
          telegram_link: "http://example.com/telegram",
          paused: false
        })

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.pause(chat_id, token_address, chain_id)

      paused_subscription = Repo.get(ChatSubscription, subscription.id)
      assert paused_subscription.paused == true
    end

    test "sends a message when subscription does not exist" do
      chat_id = 123
      token_address = "0xTokenAddress"
      chain_id = 1

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.pause(chat_id, token_address, chain_id)

      subscription = Repo.one(ChatSubscription)
      assert is_nil(subscription)
    end
  end

  describe "pause_all/1" do
    test "pauses all alerts for a chat" do
      chat_id = 123

      subscription1 =
        Repo.insert!(%ChatSubscription{
          chat_id: chat_id,
          token_address: "0xTokenAddress1",
          chain_id: 1,
          trade_size_step: Decimal.new("0.1"),
          trade_size_emoji: "💰",
          min_buy_amount: Decimal.new("0.1"),
          alert_image_url: "http://example.com/alert1.png",
          website_url: "http://example.com",
          twitter_handle: "@example",
          discord_link: "http://example.com/discord",
          telegram_link: "http://example.com/telegram",
          paused: false
        })

      subscription2 =
        Repo.insert!(%ChatSubscription{
          chat_id: chat_id,
          token_address: "0xTokenAddress2",
          chain_id: 1,
          trade_size_step: Decimal.new("0.1"),
          trade_size_emoji: "💰",
          min_buy_amount: Decimal.new("0.1"),
          alert_image_url: "http://example.com/alert2.png",
          website_url: "http://example.com",
          twitter_handle: "@example",
          discord_link: "http://example.com/discord",
          telegram_link: "http://example.com/telegram",
          paused: false
        })

      expect(SwapListener.TelegramClientMock, :send_message, fn ^chat_id, _message -> :ok end)

      ChatSubscriptionManager.pause_all(chat_id)

      paused_subscription1 = Repo.get(ChatSubscription, subscription1.id)
      paused_subscription2 = Repo.get(ChatSubscription, subscription2.id)

      assert paused_subscription1.paused == true
      assert paused_subscription2.paused == true
    end
  end
end
