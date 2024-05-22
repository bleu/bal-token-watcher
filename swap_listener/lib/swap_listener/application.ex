defmodule SwapListener.Application do
  @moduledoc false
  use Application

  alias SwapListener.BlockchainConfig

  def start(_type, _args) do
    poller_children =
      Enum.map(
        BlockchainConfig.subgraph_urls(),
        fn {network, url, chain_id} ->
          Supervisor.child_spec({SwapListener.BalancerPoller, {network, url, chain_id}},
            id: String.to_atom("BalancerPoller_#{network}")
          )
        end
      )

    children =
      [
        SwapListener.Repo,
        {Phoenix.PubSub, name: SwapListener.PubSub},
        {SwapListener.SwapListener, []},
        {SwapListener.TokenAdditionManager, []},
        SwapListener.ChatSubscriptionManager,
        # {Telegram.Poller, bots: [telegram_bot_config()]}
        {Telegram.Webhook, config: webhook_config(), bots: [telegram_bot_config()]}
      ] ++ poller_children

    opts = [
      strategy: :one_for_one,
      name: SwapListener.Supervisor,
      max_restarts: 10,
      max_seconds: 60
    ]

    Supervisor.start_link(children, opts)
  end

  defp webhook_config do
    Application.fetch_env!(:telegram, :webhook)
  end

  defp telegram_bot_config do
    token = Application.fetch_env!(:telegram, :token)
    {SwapListener.TelegramBot, token: token, max_bot_concurrency: 10}
  end
end
