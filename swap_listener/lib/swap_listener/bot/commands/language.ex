defmodule SwapListener.Bot.Commands.Language do
  @moduledoc false

  @languages %{
    "en" => "English",
    "fr" => "French",
    "es" => "Spanish",
    "pt" => "Portuguese",
    "de" => "German",
    "it" => "Italian",
    "nl" => "Dutch",
    "pl" => "Polish",
    "ru" => "Russian",
    "zh" => "Chinese",
    "ja" => "Japanese",
    "ko" => "Korean"
  }

  @telegram_client Application.compile_env(
                     :swap_listener,
                     :telegram_client,
                     SwapListener.Telegram.RateLimitedTelegramClientImpl
                   )

  def handle(chat_id, _user_id, [language_code], state) do
    if Map.has_key?(@languages, language_code) do
      new_state = Map.put(state, :language, language_code)
      @telegram_client.send_message(chat_id, "Language set to #{Map.get(@languages, language_code)}.")
      {new_state, nil}
    else
      @telegram_client.send_message(
        chat_id,
        "Invalid language code. Available languages: #{Enum.join(Map.keys(@languages), ", ")}."
      )

      {state, nil}
    end
  end

  def handle(chat_id, _user_id, _args, state) do
    @telegram_client.send_message(
      chat_id,
      "Please provide a valid language code. Available languages: #{Enum.join(Map.keys(@languages), ", ")}."
    )

    {state, nil}
  end
end
