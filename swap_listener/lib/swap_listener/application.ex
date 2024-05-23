defmodule SwapListener.Application do
  @moduledoc """
  The `SwapListener.Application` module is the entry point of the SwapListener application.
  It starts and supervises the main processes required for the application to function.

  This module defines the application's supervision tree and starts various child processes,
  ensuring they are monitored and restarted if they fail. The supervisor strategy used is
  `:one_for_one`, meaning if a child process terminates, only that process is restarted.

  The application starts the following child processes:
  - `SwapListener.Repo`: Manages database interactions.
  - `Phoenix.PubSub`: Provides a publish-subscribe system for message broadcasting.
  - `SwapListener.SwapListener`: Listens for swap events and processes them.
  - `SwapListener.TokenAdditionManager`: Manages the addition of new tokens.
  - `SwapListener.ChatSubscriptionManager`: Manages chat subscriptions for swap notifications.
  - `SwapListener.RateLimiter`: Manages rate limiting for Telegram bot interactions.
  - `Telegram.Webhook`: Manages Telegram webhook integration for bot commands.

  Additionally, if the environment is not `:test`, it starts poller processes for each subgraph URL
  defined in `BlockchainConfig.subgraph_urls/1`, using the `SwapListener.BalancerPoller` module.

  The `set_telegram_commands` function sets up commands for the Telegram bot using the
  `TelegramClientImpl`, ensuring the bot responds to user commands appropriately.
  """
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
      {Telegram.Webhook, config: webhook_config(), bots: [telegram_bot_config()]},
      # Add the new manager here
      {SwapListener.DexscreenerUrlManager, []}
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
