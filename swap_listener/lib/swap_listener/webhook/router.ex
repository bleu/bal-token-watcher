defmodule Telegram.Webhook.Router do
  @moduledoc false

  use Plug.Router, copy_opts_to_assign: :bot_routing_map

  require Logger

  plug :match
  plug Plug.Parsers, parsers: [:json], pass: ["*/*"], json_decoder: Jason
  plug :dispatch

  post "/:token" do
    update = conn.body_params
    bot_routing_map = conn.assigns.bot_routing_map
    bot_dispatch_behaviour = bot_routing_map[token]

    Logger.debug("Received update: #{inspect(update)}", bot: inspect(bot_dispatch_behaviour))

    if bot_dispatch_behaviour == nil do
      Plug.Conn.send_resp(conn, :not_found, "")
    else
      bot_dispatch_behaviour.dispatch_update(update, token)
      Plug.Conn.send_resp(conn, :ok, "")
    end
  end

  match _ do
    Plug.Conn.send_resp(conn, :not_found, "")
  end
end
