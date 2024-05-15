defmodule SwapListener.ChatSubscriptionManager do
  use GenServer
  require Logger
  alias SwapListener.Repo
  alias SwapListener.ChatSubscription
  import Ecto.Query, only: [from: 2]

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
          telegram_link: c.telegram_link
        }
      )

    Repo.all(query)
  end

  def list_subscriptions() do
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
          telegram_link: c.telegram_link
        }
      )

    Repo.all(query)
  end

  def subscribe(chat_id, token_address, chain_id) do
    # Check if subscription already exists
    query =
      from(c in ChatSubscription,
        where:
          c.chat_id == ^chat_id and c.token_address == ^token_address and c.chain_id == ^chain_id
      )

    case Repo.one(query) do
      nil ->
        changeset =
          ChatSubscription.changeset(%ChatSubscription{}, %{
            chat_id: chat_id,
            token_address: token_address,
            chain_id: chain_id,
            trade_size_step: 0.1,
            trade_size_emoji: "❤️",
            min_buy_amount: 0.1,
            alert_image_url: "default_alert_image_url",
            website_url: "default_website_url",
            twitter_handle: "default_twitter",
            discord_link: "default_discord",
            telegram_link: "default_telegram"
          })

        case Repo.insert(changeset) do
          {:ok, _subscription} ->
            handle_db_response(
              {:ok, nil},
              chat_id,
              "You have successfully subscribed to alerts for token #{token_address} on chain #{chain_id}."
            )

          {:error, changeset} ->
            Logger.debug("Failed to insert subscription for chat_id: #{chat_id}")
            Logger.debug("Changeset errors: #{inspect(changeset.errors)}")

            handle_db_response(
              {:error, changeset},
              chat_id,
              "Subscription failed due to invalid data."
            )
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
        where:
          c.chat_id == ^chat_id and c.token_address == ^token_address and c.chain_id == ^chain_id
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
        handle_db_response(
          {:ok, nil},
          chat_id,
          "You have successfully unsubscribed from all alerts."
        )

      _ ->
        handle_db_response({:ok, nil}, chat_id, "No subscriptions found to unsubscribe.")
    end
  end

  def update_settings(chat_id, settings) do
    query = from(c in ChatSubscription, where: c.chat_id == ^chat_id)
    subscriptions = Repo.all(query)

    Enum.each(subscriptions, fn subscription ->
      changeset = ChatSubscription.changeset(subscription, settings)

      case Repo.update(changeset) do
        {:ok, _subscription} ->
          handle_db_response({:ok, nil}, chat_id, "Settings updated successfully.")

        {:error, changeset} ->
          Logger.debug("Failed to update settings for chat_id: #{chat_id}")
          Logger.debug("Changeset errors: #{inspect(changeset.errors)}")
          handle_db_response({:error, changeset}, chat_id, "Failed to update settings.")
      end
    end)
  end

  defp handle_db_response({:ok, _result}, chat_id, message) do
    SwapListener.TelegramClient.send_message(chat_id, message)
  end

  defp handle_db_response({:error, _changeset}, chat_id, message) do
    SwapListener.TelegramClient.send_message(chat_id, message)
  end
end
