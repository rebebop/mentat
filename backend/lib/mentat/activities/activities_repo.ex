defmodule Mentat.Activities.ActivitiesRepo do
  import Ecto.Query, warn: false
  alias Mentat.Activities.Schemas.ActivityRecord

  def create_activity_record(attrs \\ %{}) do
    %ActivityRecord{}
    |> ActivityRecord.changeset(attrs)
    |> Repo.insert()
  end
end
