defmodule SwapListener.HttpClient do
  @moduledoc false
  @callback get(String.t()) :: {:ok, map()} | {:error, any()}
end
