defmodule SwapListener.Application do
  use Application
  alias SwapListener.BlockchainConfig

  def start(_type, _args) do
    # get only first element of the tuple
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
        {Telegram.Poller, bots: [telegram_bot_config()]}
      ] ++ poller_children

    Supervisor.start_link(children, strategy: :one_for_one, name: SwapListener.Supervisor)
  end

  defp telegram_bot_config do
    token = Application.fetch_env!(:swap_listener, :telegram_token)
    {SwapListener.TelegramBot, token: token, max_bot_concurrency: 1}
  end
end
