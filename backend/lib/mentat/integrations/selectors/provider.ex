defmodule Mentat.Integrations.Selectors.Provider do
  alias Mentat.Repo
  alias Mentat.Integrations.Schemas.Provider

  def find_provider_by_name(provider_name, user_id) do
    Repo.get_by(Provider, user_id: user_id, name: provider_name)
    |> case do
      nil -> {:error, %Ecto.NoResultsError{}}
      provider -> {:ok, provider}
    end
  end
end
