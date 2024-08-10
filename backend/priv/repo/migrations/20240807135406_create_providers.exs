defmodule Mentat.Repo.Migrations.CreateProviders do
  use Ecto.Migration

  def change do
    create table(:providers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :token, :text
      add :refresh_token, :text
      add :expires_at, :utc_datetime
      add :label, :string
      add :status, :string
      add :provider_uid, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:providers, [:user_id])
  end
end
