defmodule Mentat.IntegrationsTest do
  use Mentat.DataCase

  alias Mentat.Integrations

  describe "providers" do
    alias Mentat.Integrations.Provider

    import Mentat.IntegrationsFixtures

    @invalid_attrs %{label: nil, name: nil, status: nil}

    test "list_providers/0 returns all providers" do
      provider = provider_fixture()
      assert Integrations.list_providers() == [provider]
    end

    test "get_provider!/1 returns the provider with given id" do
      provider = provider_fixture()
      assert Integrations.get_provider!(provider.id) == provider
    end

    test "create_provider/1 with valid data creates a provider" do
      valid_attrs = %{label: "some label", name: "some name", status: :enabled}

      assert {:ok, %Provider{} = provider} = Integrations.create_provider(valid_attrs)
      assert provider.label == "some label"
      assert provider.name == "some name"
      assert provider.status == :enabled
    end

    test "create_provider/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Integrations.create_provider(@invalid_attrs)
    end

    test "update_provider/2 with valid data updates the provider" do
      provider = provider_fixture()
      update_attrs = %{label: "some updated label", name: "some updated name", status: :disabled}

      assert {:ok, %Provider{} = provider} = Integrations.update_provider(provider, update_attrs)
      assert provider.label == "some updated label"
      assert provider.name == "some updated name"
      assert provider.status == :disabled
    end

    test "update_provider/2 with invalid data returns error changeset" do
      provider = provider_fixture()
      assert {:error, %Ecto.Changeset{}} = Integrations.update_provider(provider, @invalid_attrs)
      assert provider == Integrations.get_provider!(provider.id)
    end

    test "delete_provider/1 deletes the provider" do
      provider = provider_fixture()
      assert {:ok, %Provider{}} = Integrations.delete_provider(provider)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_provider!(provider.id) end
    end

    test "change_provider/1 returns a provider changeset" do
      provider = provider_fixture()
      assert %Ecto.Changeset{} = Integrations.change_provider(provider)
    end
  end
end
