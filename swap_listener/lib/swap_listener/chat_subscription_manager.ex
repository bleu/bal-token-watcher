defmodule SwapListener.ChatSubscriptionManager do
  @moduledoc false
  use GenServer

  import Ecto.Query

  alias SwapListener.ChatSubscription
  alias SwapListener.Repo

  require Logger

  @telegram_client Application.compile_env(:swap_listener, :telegram_client, SwapListener.RateLimitedTelegramClientImpl)

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def archive_subscriptions(chat_id) do
    Logger.info("Archiving all subscriptions for chat: #{chat_id}")

    Repo.transaction(fn ->
      Repo.update_all(from(c in ChatSubscription, where: c.chat_id == ^chat_id), set: [archived_at: DateTime.utc_now()])
    end)
  end

  def list_subscriptions(chat_id) do
    query =
      from(c in ChatSubscription,
        where: c.chat_id == ^chat_id and is_nil(c.archived_at),
        order_by: [asc: c.chain_id, asc: c.token_address],
        select: %{
          chat_id: c.chat_id,
          chain_id: c.chain_id,
          token_address: c.token_address,
          chain_id: c.chain_id,
          trade_size_step: c.trade_size_step,
          trade_size_emoji: c.trade_size_emoji,
          min_buy_amount: c.min_buy_amount,
          alert_image_url: c.alert_image_url,
          website_url: c.website_url,
          twitter_handle: c.twitter_handle,
          discord_link: c.discord_link,
          telegram_link: c.telegram_link,
          paused: c.paused
        }
      )

    Repo.all(query)
  end

  def list_subscriptions do
    query =
      from(c in ChatSubscription,
        where: is_nil(c.archived_at),
        select: %{
          chat_id: c.chat_id,
          chain_id: c.chain_id,
          token_address: c.token_address,
          chain_id: c.chain_id,
          trade_size_step: c.trade_size_step,
          trade_size_emoji: c.trade_size_emoji,
          min_buy_amount: c.min_buy_amount,
          alert_image_url: c.alert_image_url,
          website_url: c.website_url,
          twitter_handle: c.twitter_handle,
          discord_link: c.discord_link,
          telegram_link: c.telegram_link,
          paused: c.paused
        }
      )

    Repo.all(query)
  end

  def subscribe(chat_id, state) do
    token_address = state.token_address
    chain_id = state.chain_id

    query =
      from(c in ChatSubscription,
        where: c.chat_id == ^chat_id and c.token_address == ^token_address and c.chain_id == ^chain_id
      )

    case Repo.one(query) do
      nil ->
        changeset =
          ChatSubscription.changeset(%ChatSubscription{}, %{
            chat_id: chat_id,
            token_address: token_address,
            chain_id: chain_id,
            trade_size_step: state[:trade_size_step] || 0.1,
            trade_size_emoji: state[:trade_size_emoji] || "💰",
            min_buy_amount: state[:min_buy_amount] || 0.1,
            alert_image_url: state[:alert_image_url] || nil,
            website_url: state[:website_url] || nil,
            twitter_handle: state[:twitter_handle] || nil,
            discord_link: state[:discord_link] || nil,
            telegram_link: state[:telegram_link] || nil,
            paused: false
          })

        case Repo.insert(changeset) do
          {:ok, _subscription} ->
            handle_db_response(
              {:ok, nil},
              chat_id,
              "You have successfully subscribed to alerts for token #{token_address} on chain #{chain_id}."
            )

          {:error, changeset} ->
            Logger.info("Failed to insert subscription for chat_id: #{chat_id}")
            Logger.info("Changeset errors: #{inspect(changeset.errors)}")
            handle_db_response({:error, changeset}, chat_id, "Subscription failed due to invalid data.")
        end

      _ ->
        handle_db_response(
          {:error, nil},
          chat_id,
          "You are already subscribed to alerts for token #{token_address} on chain #{chain_id}."
        )
    end
  end

  def unsubscribe(chat_id, token_address, chain_id) do
    query =
      from(c in ChatSubscription,
        where: c.chat_id == ^chat_id and c.token_address == ^token_address and c.chain_id == ^chain_id
      )

    case Repo.delete_all(query) do
      {count, _} when count > 0 ->
        handle_db_response(
          {:ok, nil},
          chat_id,
          "You have successfully unsubscribed from alerts for token #{token_address} on chain #{chain_id}."
        )

      _ ->
        handle_db_response({:ok, nil}, chat_id, "No subscriptions found to unsubscribe.")
    end
  end

  def unsubscribe(chat_id) do
    query = from(c in ChatSubscription, where: c.chat_id == ^chat_id)

    case Repo.delete_all(query) do
      {count, _} when count > 0 ->
        handle_db_response({:ok, nil}, chat_id, "You have successfully unsubscribed from all alerts.")

      _ ->
        handle_db_response({:ok, nil}, chat_id, "No subscriptions found to unsubscribe.")
    end
  end

  def update_subscription_settings(chat_id, token_address, chain_id, settings) do
    query =
      from(c in ChatSubscription,
        where: c.chat_id == ^chat_id and c.token_address == ^token_address and c.chain_id == ^chain_id
      )

    case Repo.one(query) do
      nil ->
        handle_db_response({:error, nil}, chat_id, "No subscription found for #{token_address} on chain #{chain_id}.")

      subscription ->
        changeset = ChatSubscription.changeset(subscription, settings)

        case Repo.update(changeset) do
          {:ok, updated_subscription} ->
            handle_db_response(
              {:ok, nil},
              chat_id,
              "Settings updated successfully for #{token_address} on chain #{chain_id}. \nNew settings: #{format_subscription_settings(updated_subscription)}."
            )

          {:error, changeset} ->
            Logger.debug("Failed to update settings for chat_id: #{chat_id}")
            Logger.debug("Changeset errors: #{inspect(changeset.errors)}")
            handle_db_response({:error, changeset}, chat_id, "Failed to update settings.")
        end
    end
  end

  def pause(chat_id, token_address, chain_id) do
    update_pause_status(chat_id, token_address, chain_id, true, "paused")
  end

  def pause_all(chat_id) do
    update_pause_status_all(chat_id, true, "paused")
  end

  def restart(chat_id, token_address, chain_id) do
    update_pause_status(chat_id, token_address, chain_id, false, "restarted")
  end

  def restart_all(chat_id) do
    update_pause_status_all(chat_id, false, "restarted")
  end

  defp update_pause_status(chat_id, token_address, chain_id, status, action) do
    query =
      from(c in ChatSubscription,
        where: c.chat_id == ^chat_id and c.token_address == ^token_address and c.chain_id == ^chain_id
      )

    case Repo.one(query) do
      nil ->
        handle_db_response({:error, nil}, chat_id, "No subscription found for #{token_address} on chain #{chain_id}.")

      subscription ->
        changeset = ChatSubscription.changeset(subscription, %{paused: status})

        case Repo.update(changeset) do
          {:ok, _subscription} ->
            handle_db_response({:ok, nil}, chat_id, "Alerts #{action} for #{token_address} on chain #{chain_id}.")

          {:error, changeset} ->
            Logger.info("Failed to insert/update subscription for chat_id: #{chat_id}")
            Logger.info("Changeset errors: #{inspect(changeset.errors)}")
            handle_db_response({:error, changeset}, chat_id, "Failed to #{action} alerts.")
        end
    end
  end

  defp update_pause_status_all(chat_id, status, action) do
    query = from(c in ChatSubscription, where: c.chat_id == ^chat_id)

    subscriptions = Repo.all(query)

    if Enum.empty?(subscriptions) do
      handle_db_response({:ok, nil}, chat_id, "No subscriptions found to #{action}.")
    else
      results =
        Enum.map(subscriptions, fn subscription ->
          changeset = ChatSubscription.changeset(subscription, %{paused: status})
          Repo.update(changeset)
        end)

      if Enum.all?(results, &match?({:ok, _}, &1)) do
        handle_db_response({:ok, nil}, chat_id, "All alerts #{action}.")
      else
        Logger.debug("Failed to #{action} some alerts for chat_id: #{chat_id}")

        Enum.each(results, fn
          {:error, changeset} ->
            Logger.debug("Changeset errors: #{inspect(changeset.errors)}")

          _ ->
            :ok
        end)

        handle_db_response({:error, nil}, chat_id, "Failed to #{action} some alerts.")
      end
    end
  end

  defp handle_db_response({:ok, _result}, chat_id, message) do
    @telegram_client.send_message(chat_id, "✅ #{message}")
  end

  defp handle_db_response({:error, _changeset}, chat_id, message) do
    @telegram_client.send_message(chat_id, "❌ #{message}")
  end

  def adjust_min_buy_amount(subscription, new_min_buy_amount) do
    changeset = ChatSubscription.changeset(subscription, %{min_buy_amount: new_min_buy_amount})

    case Repo.update(changeset) do
      {:ok, _subscription} -> :ok
      {:error, changeset} -> Logger.error("Failed to adjust min_buy_amount: #{inspect(changeset.errors)}")
    end
  end

  defp format_subscription_settings(subscription) do
    """
    *Token Address:* #{subscription.token_address}
    *Chain ID:* #{subscription.chain_id}
    *Trade Size Step:* #{subscription.trade_size_step}
    *Trade Size Emoji:* #{subscription.trade_size_emoji}
    *Min Buy Amount:* #{subscription.min_buy_amount}
    *Alert Image URL:* #{subscription.alert_image_url}
    *Website URL:* #{subscription.website_url}
    *Twitter Handle:* #{subscription.twitter_handle}
    *Discord Link:* #{subscription.discord_link}
    *Telegram Link:* #{subscription.telegram_link}
    """
  end
end
