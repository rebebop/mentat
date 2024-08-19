defmodule Mentat.Activities.Services.ActivityRecord do
  alias Mentat.Activities.Schemas.ActivityRecord
  alias Mentat.Activities.ActivitiesRepo
  alias Mentat.Repo

  def save_activity_record(user_id, attrs) do
    ActivitiesRepo.create_activity_record(Map.merge(attrs, %{user_id: user_id}))
  end

  def save_or_update_activity_records(activities) do
    timestamp_now = DateTime.utc_now() |> DateTime.truncate(:second)

    Repo.insert_all(
      ActivityRecord,
      activities |> Enum.map(&Map.merge(&1, %{inserted_at: timestamp_now, updated_at: timestamp_now}))
    )
  end
end
