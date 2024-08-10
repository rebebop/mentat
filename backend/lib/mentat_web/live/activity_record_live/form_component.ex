defmodule MentatWeb.ActivityRecordLive.FormComponent do
  use MentatWeb, :live_component

  alias Mentat.Integrations
  alias Mentat.Activities

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage activity_record records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="activity_record-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:start_time]} type="datetime-local" label="Start time" />
        <.input field={@form[:end_time]} type="datetime-local" label="End time" />
        <.input field={@form[:value]} type="number" label="Value" step="any" />
        <%!-- <.input --%>
        <%!--   field={@form[:tags]} --%>
        <%!--   type="select" --%>
        <%!--   multiple --%>
        <%!--   label="Tags" --%>
        <%!--   options={[{"Option 1", "option1"}, {"Option 2", "option2"}]} --%>
        <%!-- /> --%>
        <.input
          field={@form[:measuring_scale]}
          type="select"
          label="Measuring scale"
          prompt="Choose a value"
          options={Ecto.Enum.values(Mentat.Activities.ActivityRecord, :measuring_scale)}
        />
        <.input
          field={@form[:provider_id]}
          type="select"
          label="Provider"
          prompt="Choose a value"
          options={Integrations.list_providers() |> Enum.map(&{&1.label, &1.id})}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Activity record</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{activity_record: activity_record} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Activities.change_activity_record(activity_record))
     end)}
  end

  @impl true
  def handle_event("validate", %{"activity_record" => activity_record_params}, socket) do
    changeset =
      Activities.change_activity_record(socket.assigns.activity_record, activity_record_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"activity_record" => activity_record_params}, socket) do
    save_activity_record(socket, socket.assigns.action, activity_record_params)
  end

  defp save_activity_record(socket, :edit, activity_record_params) do
    case Activities.update_activity_record(socket.assigns.activity_record, activity_record_params) do
      {:ok, activity_record} ->
        notify_parent({:saved, activity_record})

        {:noreply,
         socket
         |> put_flash(:info, "Activity record updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_activity_record(socket, :new, activity_record_params) do
    case Activities.create_activity_record(
           Map.merge(activity_record_params, %{
             "user_id" => socket.assigns.current_user.id
           })
         ) do
      {:ok, activity_record} ->
        notify_parent({:saved, activity_record})

        {:noreply,
         socket
         |> put_flash(:info, "Activity record created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
