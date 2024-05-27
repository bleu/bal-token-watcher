defmodule SwapListener.Telegram.RateLimiter do
  @moduledoc false
  use GenServer

  require Logger

  @default_max_messages_per_second 30
  @default_interval 1000
  @default_throttle_threshold 25
  @reset_interval 10_000

  def start_link(opts \\ []) do
    initial_state = %{
      queue: :queue.new(),
      messages_sent: 0,
      throttle_level: 0,
      max_messages_per_second: Keyword.get(opts, :max_messages_per_second, @default_max_messages_per_second),
      interval: Keyword.get(opts, :interval, @default_interval),
      throttle_threshold: Keyword.get(opts, :throttle_threshold, @default_throttle_threshold)
    }

    GenServer.start_link(__MODULE__, initial_state, name: Keyword.get(opts, :name, __MODULE__))
  end

  def init(state) do
    Logger.debug("Initializing RateLimiter with state: #{inspect(state)}")
    schedule_check(state[:interval])
    schedule_reset(@reset_interval)
    {:ok, state}
  end

  def schedule_send(pid, message_type, chat_id, content, opts \\ []) do
    GenServer.cast(pid, {:schedule_send, message_type, chat_id, content, opts})
  end

  def clear_messages_for_chat(chat_id) do
    GenServer.cast(__MODULE__, {:clear_messages_for_chat, chat_id})
  end

  def handle_cast({:schedule_send, message_type, chat_id, content, opts}, %{queue: queue} = state) do
    updated_queue = :queue.in({message_type, chat_id, content, opts}, queue)
    Logger.debug("Message scheduled. Queue length: #{:queue.len(updated_queue)}")
    {:noreply, %{state | queue: updated_queue}}
  end

  def handle_cast({:clear_messages_for_chat, chat_id}, %{queue: queue} = state) do
    updated_queue = :queue.filter(fn {_, id, _, _} -> id != chat_id end, queue)
    Logger.debug("Cleared messages for chat #{chat_id}. Queue length: #{:queue.len(updated_queue)}")
    {:noreply, %{state | queue: updated_queue}}
  end

  def handle_info(
        :check_queue,
        %{
          queue: queue,
          messages_sent: messages_sent,
          throttle_level: throttle_level,
          max_messages_per_second: max_messages_per_second,
          interval: interval,
          throttle_threshold: throttle_threshold
        } = state
      ) do
    Logger.debug(
      "Checking queue. Messages sent: #{messages_sent}, Throttle level: #{throttle_level}, Queue length: #{:queue.len(queue)}"
    )

    max_messages = max_messages_per_second - messages_sent

    {new_queue, new_messages_sent, new_throttle_level} =
      if messages_sent >= throttle_threshold do
        adjust_throttle(throttle_level, queue)
      else
        send_next_items(queue, messages_sent, throttle_level, max_messages)
      end

    Logger.debug(
      "Queue processed. New messages sent: #{new_messages_sent}, New throttle level: #{new_throttle_level}, Queue length: #{:queue.len(new_queue)}"
    )

    schedule_check(interval)
    {:noreply, %{state | queue: new_queue, messages_sent: new_messages_sent, throttle_level: new_throttle_level}}
  end

  def handle_info(:reset_counter, state) do
    Logger.debug("Resetting messages_sent counter")
    schedule_reset(@reset_interval)
    {:noreply, %{state | messages_sent: 0}}
  end

  defp send_next_items(queue, messages_sent, throttle_level, max_messages) do
    {new_queue, new_messages_sent} =
      Enum.reduce_while(1..max_messages, {queue, messages_sent}, fn _, {q, ms} ->
        case :queue.out(q) do
          {{:value, {message_type, chat_id, content, opts}}, updated_queue} ->
            Logger.debug("Sending #{message_type} to #{chat_id}")

            result =
              case message_type do
                :message ->
                  SwapListener.Telegram.TelegramClientImpl.send_message(chat_id, content, opts)

                :photo ->
                  SwapListener.Telegram.TelegramClientImpl.send_photo(chat_id, content, opts[:caption], opts)

                :animation ->
                  SwapListener.Telegram.TelegramClientImpl.send_animation(chat_id, content, opts[:caption], opts)
              end

            case result do
              {:ok, _response} ->
                Logger.debug("Successfully sent #{message_type} to #{chat_id}")
                {:cont, {updated_queue, ms + 1}}

              {:error, reason} ->
                Logger.error("Failed to send #{message_type} to #{chat_id}: #{inspect(reason)}")
                {:halt, {updated_queue, ms}}
            end

          {:empty, _} ->
            Logger.debug("Queue is empty, no more messages to send")
            {:halt, {q, ms}}
        end
      end)

    {new_queue, new_messages_sent, throttle_level}
  end

  defp adjust_throttle(throttle_level, queue) do
    new_throttle_level = throttle_level + 1
    Logger.warning("Throttle level increased to #{new_throttle_level}")
    {queue, 0, new_throttle_level}
  end

  defp schedule_check(interval) do
    Process.send_after(self(), :check_queue, interval)
  end

  defp schedule_reset(interval) do
    Process.send_after(self(), :reset_counter, interval)
  end
end
