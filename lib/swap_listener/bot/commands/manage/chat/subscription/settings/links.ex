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
      links
      |> Enum.with_index()
      |> Enum.map(fn {link, index} ->
        label =
          if link["default"],
            do: "(#{index}) #{link["label"]} (default #{link["id"]})",
            else: "(#{index}) #{link["label"]} -> #{link["url"]}"

        [%{text: label, callback_data: "edit_link_action:manage:#{index}:#{subscription_id}"}]
      end)

    buttons =
      buttons ++
        [
          [
            %{text: "Reorder", callback_data: "edit_link_action:reorder:#{subscription_id}"},
            %{text: "Add Link", callback_data: "edit_link_action:add:#{subscription_id}"}
          ]
        ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage links for subscription:",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def edit_link_action("remove", link_index, subscription_id, chat_id, state) do
    case ChatSubscriptionManager.remove_link(subscription_id, link_index) do
      :ok -> {state, %{chat_id: chat_id, text: "Link #{link_index} has been removed."}}
      {:error, message} -> {state, %{chat_id: chat_id, text: message}}
    end
  end

  def edit_link_action("manage", link_index, subscription_id, chat_id, state) do
    buttons = [
      [
        %{text: "Toggle", callback_data: "edit_link_action:toggle:#{link_index}:#{subscription_id}"},
        %{text: "Edit Copy", callback_data: "edit_link_action:edit_label:#{link_index}:#{subscription_id}"},
        %{text: "Remove", callback_data: "edit_link_action:remove:#{link_index}:#{subscription_id}"}
      ]
    ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage link: #{link_index}",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def edit_link_action("edit_label", link_index, subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, {:edit_label, link_index}, subscription_id, "Please enter the new copy for the link:")
  end

  def edit_link_action("toggle", link_index, subscription_id, chat_id, state) do
    new_status = ChatSubscriptionManager.toggle_link_status(subscription_id, link_index)
    reply = %{chat_id: chat_id, text: "#{link_index} link has been #{new_status}."}
    {state, reply}
  end

  def edit_link_action("reorder", subscription_id, chat_id, state) do
    Utils.set_step(
      state,
      chat_id,
      :reorder_links,
      subscription_id,
      "Please enter the new order of the links in the format: 1,2,3,4,5"
    )
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

    ChatSubscriptionManager.add_link(subscription_id, label, url)
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

  def edit_link_action("custom", link_id, subscription_id, chat_id, state) do
    buttons = [
      [%{text: "Rename", callback_data: "edit_link_action:rename:#{link_id}:#{subscription_id}"}],
      [%{text: "Change URL", callback_data: "edit_link_action:change_url:#{link_id}:#{subscription_id}"}],
      [%{text: "Remove", callback_data: "edit_link_action:remove:#{link_id}:#{subscription_id}"}]
    ]

    reply_markup = %{inline_keyboard: buttons}

    reply = %{
      chat_id: chat_id,
      text: "Manage link: #{link_id}",
      reply_markup: reply_markup
    }

    {state, reply}
  end

  def edit_link_action("rename", link_id, subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, {:rename, link_id}, subscription_id, "Please enter the new name for the link:")
  end

  def edit_link_action("change_url", link_id, subscription_id, chat_id, state) do
    Utils.set_step(state, chat_id, {:change_url, link_id}, subscription_id, "Please enter the new URL for the link:")
  end

  def edit_link_action("remove", link_id, subscription_id, chat_id, state) do
    ChatSubscriptionManager.remove_custom_link(subscription_id, link_id)
    reply = %{chat_id: chat_id, text: "Link #{link_id} has been removed."}
    {state, reply}
  end
end
