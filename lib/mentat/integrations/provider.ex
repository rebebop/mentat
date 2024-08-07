defmodule Mentat.Integrations.Provider do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "providers" do
    field :label, :string
    field :name, :string
    field :status, Ecto.Enum, values: [:enabled, :disabled]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(provider, attrs) do
    provider
    |> cast(attrs, [:name, :label, :status])
    |> validate_required([:name, :label, :status])
  end
end
