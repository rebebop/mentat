defmodule Mentat.IntegrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mentat.Integrations` context.
  """

  @doc """
  Generate a provider.
  """
  def provider_fixture(attrs \\ %{}) do
    {:ok, provider} =
      attrs
      |> Enum.into(%{
        label: "some label",
        name: "some name",
        status: :enabled
      })
      |> Mentat.Integrations.create_provider()

    provider
  end
end
