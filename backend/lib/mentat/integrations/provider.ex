defmodule Mentat.Integrations.Provider do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mentat.Accounts.User

  @required_fields [:name, :status, :user_id]
  @optional_fields [:label, :token, :refresh_token, :expires_at]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "providers" do
    field :label, :string
    field :name, Ecto.Enum, values: [:custom, :fitbit]
    field :status, Ecto.Enum, values: [:enabled, :disabled]
    field :token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime
    field :provider_uid, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(provider, attrs) do
    provider
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
