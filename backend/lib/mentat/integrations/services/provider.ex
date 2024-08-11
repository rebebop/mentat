defmodule Mentat.Integrations.Services.Provider do
  alias Mentat.Integrations.Selectors
  alias Mentat.Integrations.IntegrationsRepo

  def save_provider(provider_name, user_id, attrs) do
    save_provider(
      Selectors.Provider.find_provider_by_name(provider_name, user_id),
      Map.merge(attrs, %{user_id: user_id})
    )
  end

  defp save_provider({:ok, provider}, attrs),
    do: IntegrationsRepo.update_provider(provider, attrs)

  defp save_provider({:error, %Ecto.NoResultsError{}}, attrs),
    do: IntegrationsRepo.add_provider(attrs)
end
