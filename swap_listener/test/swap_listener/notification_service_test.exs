# test/swap_listener/notification_service_test.exs
defmodule SwapListener.NotificationServiceTest do
  use SwapListener.DataCase, async: true
  alias SwapListener.NotificationService

  test "handle_notification processes valid notification" do
    notification = %{
      "tokenIn" => "0xTokenIn",
      "tokenOut" => "0xTokenOut",
      "amountIn" => 1000,
      "amountOut" => 2000,
      "poolId" => "0xPoolId",
      "chainId" => 1
    }

    assert {:ok, _details} = NotificationService.handle_notification(notification)
  end
end
