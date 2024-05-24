defmodule SwapListener.RateLimiter do
  @moduledoc false
  use GenServer

  import Ecto.Query

  alias SwapListener.ChatSubscription
  alias SwapListener.ChatSubscriptionManager
  alias SwapListener.Repo

  require Logger

  @telegram_client SwapListener.TelegramClientImpl

  @max_messages_per_second 30
  @interval :timer.seconds(1)
  @throttle_threshold 25
  @min_buy_amount_levels [0.1, 1, 10, 100]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{queue: :queue.new(), messages_sent: 0, throttle_level: 0}, name: __MODULE__)
  end

  def init(state) do
    Logger.debug("Initializing RateLimiter with state: #{inspect(state)}")
    schedule_check()
    {:ok, state}
  end

  def schedule_send_message(chat_id, text) do
    Logger.debug("Scheduling message to #{chat_id}: #{text}")
    GenServer.cast(__MODULE__, {:schedule_send_message, chat_id, text})
  end

  def schedule_send_photo(chat_id, photo_url, caption \\ "") do
    Logger.debug("Scheduling photo to #{chat_id}: #{photo_url} with caption: #{caption}")
    GenServer.cast(__MODULE__, {:schedule_send_photo, chat_id, photo_url, caption})
  end

  def clear_messages_for_chat(chat_id) do
    Logger.debug("Clearing messages for chat_id: #{chat_id}")
    GenServer.cast(__MODULE__, {:clear_messages_for_chat, chat_id})
  end

  def handle_cast({:schedule_send_message, chat_id, text}, %{queue: queue} = state) do
    Logger.debug("Handling cast for send_message")
    updated_queue = :queue.in({:message, chat_id, text}, queue)
    {:noreply, %{state | queue: updated_queue}}
  end

  def handle_cast({:schedule_send_photo, chat_id, photo_url, caption}, %{queue: queue} = state) do
    Logger.debug("Handling cast for send_photo")
    updated_queue = :queue.in({:photo, chat_id, photo_url, caption}, queue)
    {:noreply, %{state | queue: updated_queue}}
  end

  def handle_cast({:clear_messages_for_chat, chat_id}, %{queue: queue} = state) do
    Logger.debug("Clearing messages for chat_id: #{chat_id}")

    updated_queue =
      :queue.filter(
        fn
          {:message, ^chat_id, _} -> false
          {:photo, ^chat_id, _, _} -> false
          _ -> true
        end,
        queue
      )

    {:noreply, %{state | queue: updated_queue}}
  end

  def handle_info(:check_queue, %{queue: queue, messages_sent: messages_sent, throttle_level: throttle_level} = state) do
    Logger.debug("Checking queue. Messages sent: #{messages_sent}, Throttle level: #{throttle_level}")
    max_messages = @max_messages_per_second - messages_sent

    {queue, messages_sent, throttle_level} =
      if messages_sent >= @throttle_threshold do
        adjust_throttle(throttle_level, queue)
      else
        send_next_items(queue, messages_sent, throttle_level, max_messages)
      end

    Logger.debug("Queue processed. New messages sent: #{messages_sent}, New throttle level: #{throttle_level}")

    # Ensure there is a delay before the next check
    Process.send_after(self(), :check_queue, @interval)

    {:noreply, %{state | queue: queue, messages_sent: messages_sent, throttle_level: throttle_level}}
  end

  defp send_next_items(queue, messages_sent, throttle_level, max_messages) do
    {new_queue, new_messages_sent} =
      Enum.reduce_while(1..max_messages, {queue, messages_sent}, fn _, {q, ms} ->
        case :queue.out(q) do
          {{:value, {:message, chat_id, text}}, updated_queue} ->
            Logger.debug("Sending message to #{chat_id}: #{text}")

            case @telegram_client.send_message(chat_id, text) do
              :ok ->
                {:cont, {updated_queue, ms + 1}}

              {:error, reason} ->
                Logger.error("Failed to send message to #{chat_id}: #{inspect(reason)}")
                {:cont, {updated_queue, ms}}
            end

          {{:value, {:photo, chat_id, photo_url, caption}}, updated_queue} ->
            Logger.debug("Sending photo to #{chat_id}: #{photo_url} with caption: #{caption}")

            case @telegram_client.send_photo(chat_id, photo_url, caption) do
              :ok ->
                {:cont, {updated_queue, ms + 1}}

              {:error, reason} ->
                Logger.error("Failed to send photo to #{chat_id}: #{inspect(reason)}")
                {:cont, {updated_queue, ms}}
            end

          {:empty, _} ->
            {:halt, {q, ms}}
        end
      end)

    {new_queue, new_messages_sent, throttle_level}
  end

  defp adjust_throttle(throttle_level, queue) do
    new_throttle_level = min(throttle_level + 1, length(@min_buy_amount_levels) - 1)
    new_min_buy_amount = Enum.at(@min_buy_amount_levels, new_throttle_level)
    Logger.warning("Throttle level increased to #{new_throttle_level}, adjusting min buy amount to #{new_min_buy_amount}")

    # Notify users in a friendly manner that the threshold is being adjusted
    notify_users_of_adjustment(new_min_buy_amount)
    Repo.transaction(fn -> adjust_min_buy_amount_for_all_subscriptions(new_min_buy_amount) end)

    {queue, 0, new_throttle_level}
  end

  defp adjust_min_buy_amount_for_all_subscriptions(new_min_buy_amount) do
    from(c in SwapListener.ChatSubscription)
    |> Repo.all()
    |> Enum.each(fn subscription ->
      ChatSubscriptionManager.adjust_min_buy_amount(subscription, new_min_buy_amount)
    end)
  end

  defp notify_users_of_adjustment(new_min_buy_amount) do
    from(c in ChatSubscription, distinct: c.chat_id, select: c.chat_id)
    |> Repo.all()
    |> Enum.each(fn chat_id ->
      Logger.debug("Notifying chat #{chat_id} of new min buy amount: #{new_min_buy_amount}")

      @telegram_client.send_message(
        chat_id,
        "🔔 To enhance your experience and reduce noise, we've updated the minimum buy amount to #{new_min_buy_amount}."
      )
    end)
  end

  defp schedule_check do
    Logger.debug("Scheduling next queue check")
    Process.send_after(self(), :check_queue, @interval)
  end
end
