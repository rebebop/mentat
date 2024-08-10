defmodule Mentat.Repo.Migrations.CreateActivityRecords do
  use Ecto.Migration

  def change do
    create table(:activity_records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_time, :utc_datetime, null: false
      add :end_time, :utc_datetime, null: false
      add :value, :decimal, null: false
      add :details, :map
      add :tags, {:array, :string}
      add :measuring_scale, :integer, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :provider_id, references(:providers, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:activity_records, [:user_id])
    create index(:activity_records, [:provider_id])
    create index(:activity_records, [:measuring_scale])
  end
end
