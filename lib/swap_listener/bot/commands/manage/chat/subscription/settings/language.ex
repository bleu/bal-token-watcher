defmodule SwapListener.Bot.Commands.Manage.Chat.Subscription.Settings.Language do
  @moduledoc false
  def prompt(subscription_id, chat_id, state) do
    languages = %{
      "en" => "English",
      "zh" => "Chinese (中文)",
      "ko" => "Korean (한국어)",
      "es" => "Spanish (Español)",
      "ja" => "Japanese (日本語)",
      "pt" => "Portuguese (Português)",
      "fr" => "French (Français)",
      "ru" => "Russian (Русский)",
      "de" => "German (Deutsch)",
      "it" => "Italian (Italiano)",
      "pl" => "Polish (Polski)",
      "nl" => "Dutch (Nederlands)"
    }

    buttons =
      Enum.map(languages, fn {code, name} -> [%{text: name, callback_data: "set_language:#{code}:#{subscription_id}"}] end)

    reply_markup = %{inline_keyboard: buttons}
    reply = %{chat_id: chat_id, text: "Select your preferred language:", reply_markup: reply_markup}
    {state, reply}
  end
end
