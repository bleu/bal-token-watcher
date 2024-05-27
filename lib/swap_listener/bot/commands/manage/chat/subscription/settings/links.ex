defmodule SwapListener.Bot.Commands.Manage.Chat.Subscription.Settings.Links do
  @moduledoc false
  alias SwapListener.Bot.Commands.Manage
  alias SwapListener.Bot.Commands.Utils
  alias SwapListener.ChatSubscription.ChatSubscriptionManager

  def prompt(subscription_id, chat_id, state) do
    state = Map.put(state, :current_subscription, subscription_id)

    subscription = ChatSubscriptionManager.get_subscription_by_id(subscription_id)
    links = subscription.links

    buttons =
      Enum.map(links, fn link ->
        label = if link["default"], do: "#{link["label"]} (default)", else: "#{link["label"]} -> #{link["url"]}"
        [%{text: label, callback_data: "edit_link_action:manage:#{link["id"]}:#{subscription_id}"}]
      end)

    buttons =
      buttons ++
        [
          [%{text: "Add Link", callback_data: "edit_link_action:add:#{subscription_id}"}]
        ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage links for subscription:",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def edit_link_action("manage", link_id, subscription_id, chat_id, state) do
    buttons = [
      [%{text: "Toggle", callback_data: "edit_link_action:toggle:#{link_id}:#{subscription_id}"}],
      [%{text: "Edit Copy", callback_data: "edit_link_action:edit_label:#{link_id}:#{subscription_id}"}]
    ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage link: #{link_id}",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def edit_link_action("edit_label", link_id, subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, {:edit_label, link_id}, subscription_id, "Please enter the new copy for the link:")
  end

  def edit_link_action("toggle", link_id, subscription_id, chat_id, state) do
    new_status = ChatSubscriptionManager.toggle_link_status(subscription_id, link_id)
    reply = %{chat_id: chat_id, text: "#{link_id} link has been #{new_status}."}
    {state, reply}
  end

  def edit_link_action("add", subscription_id, chat_id, state) do
    state = Map.put(state, :current_subscription, subscription_id)

    Utils.set_step(
      state,
      chat_id,
      :add_link,
      subscription_id,
      "Please enter the label and URL for the new link in the format: label,url"
    )
  end

  def handle_step(:add_link, %{text: text}, chat_id, state) do
    [label, url] = String.split(text, ",", parts: 2)
    subscription_id = state[:current_subscription]

    ChatSubscriptionManager.add_custom_link(subscription_id, label, url)
    reply = %{chat_id: chat_id, text: "Link '#{label}' with URL '#{url}' has been added."}
    {state, reply}
  end

  def edit_link_action("manage_custom_links", "custom", subscription_id, chat_id, state) do
    state = Map.put(state, :current_subscription, subscription_id)

    custom_links =
      case ChatSubscriptionManager.get_subscription_by_id(subscription_id) do
        nil -> []
        subscription -> Enum.filter(subscription.links, &(&1["default"] == false))
      end

    buttons =
      Enum.map(custom_links, fn link ->
        [%{text: link["label"], callback_data: "edit_link_action:custom:#{link["label"]}:#{subscription_id}"}]
      end)

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage custom links:",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def edit_link_action("custom", link_label, subscription_id, chat_id, state) do
    buttons = [
      [%{text: "Rename", callback_data: "edit_link_action:rename:#{link_label}:#{subscription_id}"}],
      [%{text: "Change URL", callback_data: "edit_link_action:change_url:#{link_label}:#{subscription_id}"}],
      [%{text: "Remove", callback_data: "edit_link_action:remove:#{link_label}:#{subscription_id}"}]
    ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage link: #{link_label}",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def edit_link_action("rename", link_label, subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, {:rename, link_label}, subscription_id, "Please enter the new name for the link:")
  end

  def edit_link_action("change_url", link_label, subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, {:change_url, link_label}, subscription_id, "Please enter the new URL for the link:")
  end

  def edit_link_action("remove", link_label, subscription_id, chat_id, state) do
    ChatSubscriptionManager.remove_custom_link(subscription_id, link_label)
    reply = %{chat_id: chat_id, text: "Link #{link_label} has been removed."}
    {state, reply}
  end
end
