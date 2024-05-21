defmodule SwapListener.TokenAdditionManager do
  @moduledoc false
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get_state, chat_id}, _from, state) do
    {:reply, Map.get(state, chat_id, %{}), state}
  end

  def handle_cast({:set_state, chat_id, key, value}, state) do
    new_state = Map.update(state, chat_id, %{key => value}, &Map.put(&1, key, value))
    {:noreply, new_state}
  end

  def handle_cast({:delete_state, chat_id}, state) do
    new_state = Map.delete(state, chat_id)
    {:noreply, new_state}
  end
end
