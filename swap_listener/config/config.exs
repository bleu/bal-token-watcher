import Config

config :swap_listener,
  ecto_repos: [SwapListener.Repo],
  telegram_client: SwapListener.RateLimitedTelegramClientImpl,
  http_client: SwapListener.HttpClientImpl,
  graphql_client: SwapListener.GraphQLClientImpl

config :honeybadger,
  api_key: System.get_env("HONEYBADGER_API_KEY"),
  use_logger: true

config :telegram,
  webserver: Telegram.WebServer.Cowboy,
  token: "7159801638:AAH4slEJzPCaroVP9NW7hGc8Ubq7j81vyCs",
  # token: System.get_env("TELEGRAM_TOKEN"),
  webhook: [
    # host: System.get_env("TELEGRAM_WEBHOOK_HOST"),
    host: "8c98529ceb27.ngrok.app",
    port: 443,
    local_port: 4000,
    max_connections: 40
  ]

config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 40_000]}

config :swap_listener, SwapListener.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "swap_listener_development",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  log_level: false

config :esbuild,
  version: "0.17.11"

config :tailwind,
  version: "3.2.7"

config :logger, level: :debug

import_config "#{config_env()}.exs"
