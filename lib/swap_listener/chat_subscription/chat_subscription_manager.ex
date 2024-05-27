defmodule SwapListener.ChatSubscription.ChatSubscriptionManager do
  @moduledoc false
  use GenServer

  import Ecto.Query

  alias SwapListener.ChatSubscription.ChatSubscription
  alias SwapListener.Infra.Repo

  require Integer
  require Logger

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def archive_subscriptions(chat_id) do
    chat_id = enforce_to_integer(chat_id)

    Logger.info("Archiving all subscriptions for chat: #{chat_id}")

    Repo.transaction(fn ->
      Repo.update_all(from(c in ChatSubscription, where: c.chat_id == ^chat_id), set: [archived_at: DateTime.utc_now()])
    end)
  end

  def list_subscriptions_from_user(user_id) do
    query =
      from(c in ChatSubscription,
        where: c.creator_id == ^user_id and is_nil(c.archived_at),
        select: %{
          id: c.id,
          chat_id: c.chat_id,
          chain_id: c.chain_id,
          token_address: c.token_address,
          trade_size_step: c.trade_size_step,
          trade_size_emoji: c.trade_size_emoji,
          min_buy_amount: c.min_buy_amount,
          alert_image_url: c.alert_image_url,
          website_url: c.website_url,
          twitter_handle: c.twitter_handle,
          discord_link: c.discord_link,
          telegram_link: c.telegram_link,
          paused: c.paused,
          language: c.language
        }
      )

    Repo.all(query)
  end

  def list_subscriptions_from_chat(chat_id) do
    chat_id = enforce_to_integer(chat_id)

    query =
      from(c in ChatSubscription,
        where: c.chat_id == ^chat_id and is_nil(c.archived_at),
        order_by: [asc: c.chain_id, asc: c.token_address],
        select: %{
          id: c.id,
          chat_id: c.chat_id,
          chain_id: c.chain_id,
          token_address: c.token_address,
          trade_size_step: c.trade_size_step,
          trade_size_emoji: c.trade_size_emoji,
          min_buy_amount: c.min_buy_amount,
          alert_image_url: c.alert_image_url,
          website_url: c.website_url,
          twitter_handle: c.twitter_handle,
          discord_link: c.discord_link,
          telegram_link: c.telegram_link,
          paused: c.paused,
          language: c.language
        }
      )

    Repo.all(query)
  end

  def list_subscriptions do
    query =
      from(c in ChatSubscription,
        where: is_nil(c.archived_at),
        select: %{
          id: c.id,
          chat_id: c.chat_id,
          chain_id: c.chain_id,
          token_address: c.token_address,
          trade_size_step: c.trade_size_step,
          trade_size_emoji: c.trade_size_emoji,
          min_buy_amount: c.min_buy_amount,
          alert_image_url: c.alert_image_url,
          website_url: c.website_url,
          twitter_handle: c.twitter_handle,
          discord_link: c.discord_link,
          telegram_link: c.telegram_link,
          paused: c.paused,
          language: c.language
        }
      )

    Repo.all(query)
  end

  def subscribe(chat_id, user_id, state) do
    token_address = state.token_address
    chain_id = state.chain_id
    chat_id = enforce_to_integer(chat_id)

    query =
      from(c in ChatSubscription,
        where:
          c.chat_id == ^chat_id and c.token_address == ^token_address and c.chain_id == ^chain_id and
            c.creator_id == ^user_id
      )

    case Repo.one(query) do
      nil ->
        changeset =
          ChatSubscription.changeset(%ChatSubscription{}, %{
            chat_id: state[:chat_id],
            chat_title: state[:chat_title],
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
            paused: false,
            creator_id: user_id
          })

        case Repo.insert(changeset) do
          {:ok, subscription} ->
            handle_db_response(
              {:ok, nil},
              chat_id,
              "You have successfully subscribed to alerts for token #{token_address} on chain #{chain_id}."
            )

            subscription

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

  def get_subscription_by_id(subscription_id) do
    subscription_id = enforce_to_integer(subscription_id)
    Repo.get(ChatSubscription, subscription_id)
  end

  def pause_subscription(subscription_id) do
    subscription_id = enforce_to_integer(subscription_id)
    Repo.update_all(from(c in ChatSubscription, where: c.id == ^subscription_id), set: [paused: true])
    :ok
  end

  def restart_subscription(subscription_id) do
    subscription_id = enforce_to_integer(subscription_id)
    Repo.update_all(from(c in ChatSubscription, where: c.id == ^subscription_id), set: [paused: false])
    :ok
  end

  def unsubscribe(subscription_id) do
    subscription_id = enforce_to_integer(subscription_id)
    Repo.delete_all(from(c in ChatSubscription, where: c.id == ^subscription_id), [])
    :ok
  end

  def pause_all(user_id) do
    user_id = enforce_to_integer(user_id)

    Repo.update_all(from(c in ChatSubscription, where: c.creator_id == ^user_id and is_nil(c.archived_at)),
      set: [paused: true]
    )
  end

  def restart_all(user_id) do
    user_id = enforce_to_integer(user_id)

    Repo.update_all(
      from(c in ChatSubscription,
        where: c.creator_id == ^user_id and is_nil(c.archived_at),
        update: [set: [paused: false]]
      ),
      []
    )
  end

  def unsubscribe_all(user_id) do
    user_id = enforce_to_integer(user_id)
    Repo.delete_all(from(c in ChatSubscription, where: c.creator_id == ^user_id and is_nil(c.archived_at)), [])
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

  defp enforce_to_integer(value) when is_integer(value), do: value
  defp enforce_to_integer(value) when is_binary(value), do: String.to_integer(value)

  def update_subscription_setting(subscription_id, setting_key, setting_value) do
    subscription = Repo.get(ChatSubscription, subscription_id)

    changeset = ChatSubscription.changeset(subscription, %{setting_key => setting_value})

    case Repo.update(changeset) do
      {:ok, _subscription} ->
        :ok

      {:error, changeset} ->
        Logger.error(
          "Failed to update setting #{setting_key} for subscription #{subscription_id}: #{inspect(changeset.errors)}"
        )

        {:error, changeset.errors}
    end
  end

  def remove_link(subscription_id, link_label) do
    subscription = Repo.get(ChatSubscription, subscription_id)

    links = subscription.links
    index = Enum.find_index(links, fn link -> link.label == link_label end)

    updated_links =
      if index do
        List.delete_at(links, index)
      else
        links
      end

    changeset = ChatSubscription.changeset(subscription, %{links: updated_links})

    case Repo.update(changeset) do
      {:ok, _subscription} -> :ok
      {:error, changeset} -> Logger.error("Failed to remove link: #{inspect(changeset.errors)}")
    end
  end

  def add_link(subscription_id, label_url_comma_separated) do
    [label, url] = String.split(label_url_comma_separated, ",", parts: 2)

    subscription = Repo.get(ChatSubscription, subscription_id)

    links = subscription.links
    new_link = %{"label" => label, "url" => url, "default" => false, "status" => "enabled"}

    updated_links = links ++ [new_link]

    changeset = ChatSubscription.changeset(subscription, %{links: updated_links})

    case Repo.update(changeset) do
      {:ok, _subscription} -> :ok
      {:error, changeset} -> Logger.error("Failed to add link: #{inspect(changeset.errors)}")
    end
  end

  def toggle_link_status(subscription_id, link_id) do
    subscription = Repo.get(ChatSubscription, subscription_id)

    links = subscription.links
    index = Enum.find_index(links, fn link -> link["id"] == link_id end)

    updated_links =
      if index do
        List.update_at(links, index, fn link ->
          case link["status"] do
            "enabled" -> %{link | "status" => "disabled"}
            "disabled" -> %{link | "status" => "enabled"}
          end
        end)
      else
        links
      end

    changeset = ChatSubscription.changeset(subscription, %{links: updated_links})

    case Repo.update(changeset) do
      {:ok, _subscription} ->
        if index != nil do
          Enum.at(updated_links, index)["status"]
        else
          :error
        end

      {:error, changeset} ->
        Logger.error("Failed to toggle link: #{inspect(changeset.errors)}")
    end
  end

  def remove_custom_link(subscription_id, link_name) do
    subscription = Repo.get(ChatSubscription, subscription_id)

    links = subscription.links
    index = Enum.find_index(links, fn link -> link.label == link_name && !link.default end)

    updated_links =
      if index do
        List.delete_at(links, index)
      else
        links
      end

    changeset = ChatSubscription.changeset(subscription, %{links: updated_links})

    case Repo.update(changeset) do
      {:ok, _subscription} -> :ok
      {:error, changeset} -> Logger.error("Failed to remove custom link: #{inspect(changeset.errors)}")
    end
  end

  def update_link_label(subscription_id, link_id, new_label) do
    subscription = Repo.get(ChatSubscription, subscription_id)

    links = subscription.links
    index = Enum.find_index(links, fn link -> link["id"] == link_id end)

    updated_links =
      if index do
        List.update_at(links, index, fn link -> %{link | "label" => new_label} end)
      else
        links
      end

    changeset = ChatSubscription.changeset(subscription, %{links: updated_links})

    case Repo.update(changeset) do
      {:ok, _subscription} -> :ok
      {:error, changeset} -> Logger.error("Failed to update link label: #{inspect(changeset.errors)}")
    end
  end
end
