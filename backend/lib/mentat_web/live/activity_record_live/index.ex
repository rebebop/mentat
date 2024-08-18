defmodule MentatWeb.ActivityRecordLive.Index do
  use MentatWeb, :live_view

  alias Mentat.Activities
  alias Mentat.Activities.Schemas.ActivityRecord

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :activity_records, Activities.list_activity_records())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Activity record")
    |> assign(:activity_record, Activities.get_activity_record!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Activity record")
    |> assign(:activity_record, %ActivityRecord{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Activity records")
    |> assign(:activity_record, nil)
  end

  @impl true
  def handle_info({MentatWeb.ActivityRecordLive.FormComponent, {:saved, activity_record}}, socket) do
    {:noreply, stream_insert(socket, :activity_records, activity_record)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activity_record = Activities.get_activity_record!(id)
    {:ok, _} = Activities.delete_activity_record(activity_record)

    {:noreply, stream_delete(socket, :activity_records, activity_record)}
  end
end
