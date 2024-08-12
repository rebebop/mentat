defmodule Mentat.Integrations.IntegrationsRepo do
  alias Mentat.Repo
  alias Mentat.Integrations.Schemas.Provider

  def add_provider(attrs \\ %{}) do
    %Provider{}
    |> Provider.changeset(attrs)
    |> Repo.insert()
  end

  def update_provider(%Provider{} = provider, attrs) do
    provider
    |> Provider.changeset(attrs)
    |> Repo.update()
  end
end
