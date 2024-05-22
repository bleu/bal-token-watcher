defmodule SwapListener.TelegramClient do
  @moduledoc false
  @callback send_message(integer(), String.t()) :: :ok | {:error, any()}
  @callback send_photo(integer(), String.t(), String.t()) :: :ok | {:error, any()}
end
