defmodule SwapListener.SwapListener do
  @moduledoc false
  use GenServer

  alias SwapListener.NotificationService

  require IEx
  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    ensure_trigger_exists()

    # Adjustments: Configure the connection with the appropriate options, including auto-reconnect.
    notifications_opts = [name: SwapListener.Notifications, auto_reconnect: true]

    # Start the Postgrex notification listener with the merged options.
    {:ok, pid} =
      Postgrex.Notifications.start_link(SwapListener.Repo.config() ++ notifications_opts)

    # Immediately listen to the "balancer_swap" channel
    {:ok, ref} = Postgrex.Notifications.listen(pid, "balancer_swap")

    {:ok, %{pid: pid, ref: ref}}
  end

  def handle_info({:notification, _pid, _ref, "balancer_swap", payload}, state) do
    Logger.debug("Received notification: #{payload}")

    case Jason.decode(payload) do
      {:ok, decoded_payload} ->
        NotificationService.handle_notification(decoded_payload)

      {:error, _error} ->
        Logger.error("Failed to decode payload: #{payload}")
    end

    {:noreply, state}
  end

  def handle_info(:timeout, state) do
    perform_regular_maintenance()
    {:noreply, state}
  end

  defp perform_regular_maintenance do
    IO.puts("Performing regular maintenance")
  end

  defp ensure_trigger_exists do
    Logger.info("Ensuring trigger exists")

    query = """
    DO $$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = '_trigger') THEN
        CREATE OR REPLACE FUNCTION public.notify__listeners()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $function$
        DECLARE
          payload json;
        BEGIN
          -- Convert the NEW record to JSON
          payload := row_to_json(NEW);

          -- Notify with the JSON payload
          PERFORM pg_notify('balancer_swap', payload::text);

          RETURN NEW;
        END;
        $function$;

        CREATE TRIGGER _trigger
        AFTER INSERT
        ON balancer_swaps
        FOR EACH ROW
        EXECUTE PROCEDURE notify__listeners();
      END IF;
    END;
    $$;
    """

    Ecto.Adapters.SQL.query!(SwapListener.Repo, query)
  end
end
