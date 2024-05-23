defmodule SwapListener.Application do
  @moduledoc false
  use Application

  alias SwapListener.BlockchainConfig
  alias SwapListener.TelegramBotSetupHelper
  alias SwapListener.TelegramClientImpl

  def start(_type, _args) do
    children = default_children() ++ poller_children()

    opts = [strategy: :one_for_one, name: SwapListener.Supervisor]

    set_telegram_commands()
    Supervisor.start_link(children, opts)
  end

  defp default_children do
    [
      SwapListener.Repo,
      {Phoenix.PubSub, name: SwapListener.PubSub},
      {SwapListener.SwapListener, []},
      {SwapListener.TokenAdditionManager, []},
      SwapListener.ChatSubscriptionManager,
      {SwapListener.RateLimiter, []},
      {Telegram.Webhook, config: webhook_config(), bots: [telegram_bot_config()]}
    ]
  end

  defp poller_children do
    if Mix.env() != :test do
      Enum.map(BlockchainConfig.subgraph_urls(), &poller_child_spec/1)
    else
      []
    end
  end

  defp poller_child_spec({network, url, chain_id}) do
    Supervisor.child_spec({SwapListener.BalancerPoller, {network, url, chain_id}},
      id: String.to_atom("BalancerPoller_#{network}")
    )
  end

  defp webhook_config, do: Application.fetch_env!(:telegram, :webhook)

  defp telegram_bot_config do
    token = Application.fetch_env!(:telegram, :token)
    {SwapListener.TelegramBot, token: token, max_bot_concurrency: 10}
  end

  defp set_telegram_commands do
    commands = TelegramBotSetupHelper.get_commands()

    formatted_commands =
      Enum.map(commands, fn {command, description} ->
        %{command: command, description: description}
      end)

    TelegramClientImpl.set_my_commands(formatted_commands)
  end
end
