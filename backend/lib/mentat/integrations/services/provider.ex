defmodule Mentat.Integrations.Services.Provider do
  alias Mentat.Integrations.Selectors
  alias Mentat.Integrations.IntegrationsRepo

  def save_provider(provider_name, user_id, attrs) do
    save_provider(
      Selectors.Provider.find_provider_by_name(provider_name, user_id),
      Map.merge(attrs, %{user_id: user_id})
    )
  end

  def save_provider({:ok, provider}, attrs),
    do: IntegrationsRepo.update_provider(provider, attrs)

  def save_provider({:error, %Ecto.NoResultsError{}}, attrs),
    do: IntegrationsRepo.add_provider(attrs)

  def enable_provider(provider) do
    IntegrationsRepo.update_provider(provider, %{enabled: true})

    provider_config = Mentat.Integrations.Util.get_provider_config!(provider.name)

    %{
      date: Calendar.strftime(DateTime.utc_now(), "%Y-%m-%d"),
      user_id: provider.user_id,
      provider_id: provider.id
    }
    |> provider_config[:sync_worker].new(schedule_in: 5)
    |> Oban.insert()
  end
end
