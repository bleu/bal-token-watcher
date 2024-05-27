import Config

config :swap_listener,
  ecto_repos: [SwapListener.Infra.Repo],
  telegram_client: SwapListener.Telegram.RateLimitedTelegramClientImpl,
  http_client: SwapListener.HttpClientImpl,
  graphql_client: SwapListener.Balancer.GraphQLClientImpl

config :honeybadger,
  api_key: System.get_env("HONEYBADGER_API_KEY"),
  use_logger: true

config :telegram,
  webserver: Telegram.WebServer.Cowboy,
  token: "7159801638:AAH4slEJzPCaroVP9NW7hGc8Ubq7j81vyCs",
  # token: System.get_env("TELEGRAM_TOKEN"),

  webhook: [
    # host: System.get_env("TELEGRAM_WEBHOOK_HOST"),
    host: "771a799e12f4.ngrok.app",
    port: 443,
    local_port: 4000,
    max_connections: 40
  ]

config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 40_000]}

config :swap_listener, SwapListener.Infra.Repo,
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

config :swap_listener, SwapListener.I18n.Gettext,
  default_locale: "en",
  locales: ~w(en fr es pt de it nl pl ru zh ja ko)

import_config "#{config_env()}.exs"
