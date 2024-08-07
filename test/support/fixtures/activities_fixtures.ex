defmodule Mentat.ActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mentat.Activities` context.
  """

  @doc """
  Generate a activity_record.
  """
  def activity_record_fixture(attrs \\ %{}) do
    {:ok, activity_record} =
      attrs
      |> Enum.into(%{
        details: %{},
        end_time: ~U[2024-08-06 13:58:00Z],
        measuring_scale: :duration,
        start_time: ~U[2024-08-06 13:58:00Z],
        tags: ["option1", "option2"],
        value: "120.5"
      })
      |> Mentat.Activities.create_activity_record()

    activity_record
  end
end
