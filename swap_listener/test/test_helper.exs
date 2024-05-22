ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SwapListener.Repo, :manual)

Mox.defmock(SwapListener.TelegramClientMock, for: SwapListener.TelegramClient)
Mox.defmock(SwapListener.GraphQLClientMock, for: SwapListener.GraphQLClient)
Mox.defmock(SwapListener.HttpClientMock, for: SwapListener.HttpClient)

Application.put_env(:swap_listener, :telegram_client, SwapListener.TelegramClientMock)
Application.put_env(:swap_listener, :graphql_client, SwapListener.GraphQLClientMock)
Application.put_env(:swap_listener, :http_client, SwapListener.HttpClientMock)
