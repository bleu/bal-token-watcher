import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

config :swap_listener, SwapListener.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "swap_listener_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox

config :honeybadger,
  environment_name: :test

# In test we don't send emails.
config :swap_listener, SwapListener.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :swap_listener, :telegram_client, SwapListener.TelegramClientMock
config :swap_listener, :http_client, SwapListener.HttpClientMock
config :swap_listener, :graphql_client, SwapListener.GraphQLClientMock
