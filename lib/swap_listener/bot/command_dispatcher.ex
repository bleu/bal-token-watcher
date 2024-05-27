defmodule SwapListener.Bot.CommandDispatcher do
  @moduledoc false

  alias SwapListener.Bot.Commands.AddToken
  alias SwapListener.Bot.Commands.ExampleMessage
  alias SwapListener.Bot.Commands.Help
  alias SwapListener.Bot.Commands.Manage
  alias SwapListener.Bot.Commands.Start

  require Logger

  @handlers %{
    "/addtoken" => {AddToken, :handle},
    "/example" => {ExampleMessage, :handle},
    "/help" => {Help, :handle},
    "/start" => {Start, :handle},
    "/manage" => {Manage, :handle}
  }

  def dispatch(command, chat_id, user_id, args, state) do
    case Map.get(@handlers, command) do
      {module, function} -> apply(module, function, [chat_id, user_id, args, state])
      _ -> {state, %{chat_id: chat_id, text: "Unknown command. Please type /help for a list of available commands."}}
    end
  end

  def handle_step(step, text, chat_id, user_id, state) do
    case step do
      :chat_selection -> AddToken.handle_step(:chat_selection, text, chat_id, user_id, state)
      :chain_id -> AddToken.handle_step(:chain_id, text, chat_id, user_id, state)
      :token_address -> AddToken.handle_step(:token_address, text, chat_id, user_id, state)
      %{updating: setting} -> Manage.handle_manage_updates(setting, text, chat_id, user_id, state)
      _ -> {state, %{chat_id: chat_id, text: "Unknown step."}}
    end
  end
end
