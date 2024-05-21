import Config

config :swap_listener,
  ecto_repos: [SwapListener.Repo]

config :honeybadger,
  api_key: "hbp_7sS3varMhzYS30XCSp33b1O13dadMp1HUtdU",
  use_logger: true

config :swap_listener, :telegram_token, "7018925703:AAHy4IExdHx7qiRcOsdmOoHKTu3IJjsMmv8"

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

config :logger, level: :info

import_config "#{config_env()}.exs"
