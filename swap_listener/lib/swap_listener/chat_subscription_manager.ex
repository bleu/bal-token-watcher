defmodule SwapListener.ChatSubscriptionManager do
  @moduledoc false
  use GenServer

  import Ecto.Query, only: [from: 2]

  alias SwapListener.ChatSubscription
  alias SwapListener.Repo

  require Logger

  @telegram_client Application.get_env(:swap_listener, :telegram_client, SwapListener.TelegramClientImpl)

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def list_subscriptions(chat_id) do
    query =
      from(c in ChatSubscription,
        where: c.chat_id == ^chat_id,
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
          {:ok, _subscription} ->
            handle_db_response(
              {:ok, nil},
              chat_id,
              "Settings updated successfully for #{token_address} on chain #{chain_id}."
            )

          {:error, changeset} ->
            Logger.debug("Failed to update settings for chat_id: #{chat_id}")
            Logger.debug("Changeset errors: #{inspect(changeset.errors)}")
            handle_db_response({:error, changeset}, chat_id, "Failed to update settings.")
        end
    end
  end

  def pause(chat_id, token_address, chain_id) do
    query =
      from(c in ChatSubscription,
        where: c.chat_id == ^chat_id and c.token_address == ^token_address and c.chain_id == ^chain_id
      )

    case Repo.one(query) do
      nil ->
        handle_db_response({:error, nil}, chat_id, "No subscription found for #{token_address} on chain #{chain_id}.")

      subscription ->
        changeset = ChatSubscription.changeset(subscription, %{paused: true})

        case Repo.update(changeset) do
          {:ok, _subscription} ->
            handle_db_response({:ok, nil}, chat_id, "Alerts paused for #{token_address} on chain #{chain_id}.")

          {:error, changeset} ->
            Logger.debug("Failed to pause alerts for chat_id: #{chat_id}")
            Logger.debug("Changeset errors: #{inspect(changeset.errors)}")
            handle_db_response({:error, changeset}, chat_id, "Failed to pause alerts.")
        end
    end
  end

  def pause_all(chat_id) do
    query = from(c in ChatSubscription, where: c.chat_id == ^chat_id)

    subscriptions = Repo.all(query)

    if Enum.empty?(subscriptions) do
      handle_db_response({:ok, nil}, chat_id, "No subscriptions found to pause.")
    else
      results =
        Enum.map(subscriptions, fn subscription ->
          changeset = ChatSubscription.changeset(subscription, %{paused: true})
          Repo.update(changeset)
        end)

      if Enum.all?(results, &match?({:ok, _}, &1)) do
        handle_db_response({:ok, nil}, chat_id, "All alerts paused.")
      else
        Logger.debug("Failed to pause some alerts for chat_id: #{chat_id}")

        Enum.each(results, fn
          {:error, changeset} ->
            Logger.debug("Changeset errors: #{inspect(changeset.errors)}")

          _ ->
            :ok
        end)

        handle_db_response({:error, nil}, chat_id, "Failed to pause some alerts.")
      end
    end
  end

  defp handle_db_response({:ok, _result}, chat_id, message) do
    @telegram_client.send_message(chat_id, "✅ #{message}")
  end

  defp handle_db_response({:error, _changeset}, chat_id, message) do
    @telegram_client.send_message(chat_id, "❌ #{message}")
  end
end
