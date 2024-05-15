Rails.application.config.after_initialize do
  def hex_to_bin(hex)
    hex = hex.gsub(/\\/, "0")
    # Prepend a '0' for padding if you don't have an even number of chars
    hex = "0" << hex unless (hex.length % 2) == 0
    hex.scan(/[A-Fa-f0-9]{2}/).inject("") { |encoded, byte| encoded << [ byte ].pack("H2") }
  end

  def send_telegram_message(message)
    chat_id = -4228801789

    Telegram.bot.send_message(chat_id: chat_id, text: message, parse_mode: "Markdown")
  end

  def notify_bot_about_start
    send_telegram_message("Listener started")
  end

  def handle_notification(payload)
    tokenInAddress = hex_to_bin(payload["tokenIn"])
    tokenOutAddress = hex_to_bin(payload["tokenOut"])
    tokenIn = Token.find_by_address(tokenInAddress)
    tokenOut = Token.find_by_address(tokenOutAddress)
    # user = User.find_by_address(payload["user"]) # Assuming you have a User model to fetch user info

    puts "TokenIn: #{tokenIn.symbol}"
    return unless tokenIn && tokenOut

    # Check if tokenIn has xaf204776c7245bF4147c2612BF6e5972Ee483701
    return unless tokenOut.symbol == "WETH"

    amountIn = payload["amountIn"].to_f / 10**tokenIn.decimals
    amountOut = payload["amountOut"].to_f / 10**tokenOut.decimals

    tx_link = "https://etherscan.io/"
    balancer_pool_link = "https://pools.balancer.exchange/#/pool/#{payload["poolId"].gsub(/\\/, "0")}"

    message = <<~MESSAGE
    *#{tokenOut.symbol} PURCHASED! 🏆🚀*
    Spent: #{amountIn.truncate(6)} #{tokenIn.symbol}
    Bought: #{amountOut.truncate(6)} #{tokenOut.symbol} 👑

    *User Info*
    # Address: #{0xabc...1234}
    Net Worth: $#{100_000} 💵

      [TX](#{tx_link}) | [Pool](#{balancer_pool_link})
    MESSAGE

    send_telegram_message(message)
  end

  def perform_regular_maintenance
    puts "Performing regular maintenance"
  end

  ActiveRecord::PostgresPubSub::Listener.listen("swap", listen_timeout: 30, notify_only: false) do |listener|
    listener.on_start do
      # When starting assume we missed something and perform regular activity
      notify_bot_about_start
    end

    listener.on_notify do |payload, channel|
      handle_notification(JSON.parse(payload))
    end

    listener.on_timeout do
      perform_regular_maintenance
    end
  end
end
