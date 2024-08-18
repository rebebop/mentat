defmodule Mentat.Activities.Services.ActivityRecord do
  alias Mentat.Activities.ActivitiesRepo

  def save_activity_record(user_id, attrs) do
    ActivitiesRepo.create_activity_record(Map.merge(attrs, %{user_id: user_id}))
  end
end
