defmodule Mentat.Activities.ActivityRecord do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:start_time, :end_time, :value, :measuring_scale, :user_id, :provider_id]
  @optional_fields [:tags, :details]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "activity_records" do
    field :value, :decimal
    field :details, :map
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :tags, {:array, :string}

    field :measuring_scale, Ecto.Enum,
      values: [
        work_min: 1,
        side_project_min: 2,
        steps: 3,
        steps_distance: 4,
        floors: 5,
        workout_min: 6,
        coffees: 7,
        alcoholic_drinks: 8,
        sleep_min: 9,
        sleep_light_min: 10,
        sleep_deep_min: 11,
        sleep_rem_min: 12,
        sleep_awake_min: 13,
        sleep_awakenings: 14,
        meditation_min: 15,
        weight: 16,
        heartrate: 17,
        heartrate_resting: 18,
        heartrate_variability: 19,
        reading_min: 20
      ]

    belongs_to :user, User
    belongs_to :provider, Provider

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity_record, attrs) do
    activity_record
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
