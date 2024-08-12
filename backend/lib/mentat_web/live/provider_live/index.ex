defmodule MentatWeb.ProviderLive.Index do
  use MentatWeb, :live_view

  alias Mentat.Integrations
  alias Mentat.Integrations.Schemas.Provider

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :providers, Integrations.list_providers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Provider")
    |> assign(:provider, Integrations.get_provider!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Provider")
    |> assign(:provider, %Provider{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Providers")
    |> assign(:provider, nil)
  end

  @impl true
  def handle_info({MentatWeb.ProviderLive.FormComponent, {:saved, provider}}, socket) do
    {:noreply, stream_insert(socket, :providers, provider)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    provider = Integrations.get_provider!(id)
    {:ok, _} = Integrations.delete_provider(provider)

    {:noreply, stream_delete(socket, :providers, provider)}
  end
end
