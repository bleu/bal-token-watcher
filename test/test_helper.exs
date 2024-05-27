ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SwapListener.Infra.Repo, :manual)

Mox.defmock(SwapListener.TelegramClientMock, for: SwapListener.TelegramClient)
Mox.defmock(SwapListener.Balancer.GraphQLClientMock, for: SwapListener.Balancer.GraphQLClient)
Mox.defmock(SwapListener.HttpClientMock, for: SwapListener.HttpClient)

Application.put_env(:swap_listener, :telegram_client, SwapListener.TelegramClientMock)
Application.put_env(:swap_listener, :graphql_client, SwapListener.Balancer.GraphQLClientMock)
Application.put_env(:swap_listener, :http_client, SwapListener.HttpClientMock)
