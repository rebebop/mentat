defmodule Mentat.ActivitiesTest do
  use Mentat.DataCase

  alias Mentat.Activities

  describe "activity_records" do
    alias Mentat.Activities.ActivityRecord

    import Mentat.ActivitiesFixtures

    @invalid_attrs %{value: nil, details: nil, start_time: nil, end_time: nil, tags: nil, measuring_scale: nil}

    test "list_activity_records/0 returns all activity_records" do
      activity_record = activity_record_fixture()
      assert Activities.list_activity_records() == [activity_record]
    end

    test "get_activity_record!/1 returns the activity_record with given id" do
      activity_record = activity_record_fixture()
      assert Activities.get_activity_record!(activity_record.id) == activity_record
    end

    test "create_activity_record/1 with valid data creates a activity_record" do
      valid_attrs = %{value: "120.5", details: %{}, start_time: ~U[2024-08-06 13:58:00Z], end_time: ~U[2024-08-06 13:58:00Z], tags: ["option1", "option2"], measuring_scale: :duration}

      assert {:ok, %ActivityRecord{} = activity_record} = Activities.create_activity_record(valid_attrs)
      assert activity_record.value == Decimal.new("120.5")
      assert activity_record.details == %{}
      assert activity_record.start_time == ~U[2024-08-06 13:58:00Z]
      assert activity_record.end_time == ~U[2024-08-06 13:58:00Z]
      assert activity_record.tags == ["option1", "option2"]
      assert activity_record.measuring_scale == :duration
    end

    test "create_activity_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_activity_record(@invalid_attrs)
    end

    test "update_activity_record/2 with valid data updates the activity_record" do
      activity_record = activity_record_fixture()
      update_attrs = %{value: "456.7", details: %{}, start_time: ~U[2024-08-07 13:58:00Z], end_time: ~U[2024-08-07 13:58:00Z], tags: ["option1"], measuring_scale: :duration}

      assert {:ok, %ActivityRecord{} = activity_record} = Activities.update_activity_record(activity_record, update_attrs)
      assert activity_record.value == Decimal.new("456.7")
      assert activity_record.details == %{}
      assert activity_record.start_time == ~U[2024-08-07 13:58:00Z]
      assert activity_record.end_time == ~U[2024-08-07 13:58:00Z]
      assert activity_record.tags == ["option1"]
      assert activity_record.measuring_scale == :duration
    end

    test "update_activity_record/2 with invalid data returns error changeset" do
      activity_record = activity_record_fixture()
      assert {:error, %Ecto.Changeset{}} = Activities.update_activity_record(activity_record, @invalid_attrs)
      assert activity_record == Activities.get_activity_record!(activity_record.id)
    end

    test "delete_activity_record/1 deletes the activity_record" do
      activity_record = activity_record_fixture()
      assert {:ok, %ActivityRecord{}} = Activities.delete_activity_record(activity_record)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_activity_record!(activity_record.id) end
    end

    test "change_activity_record/1 returns a activity_record changeset" do
      activity_record = activity_record_fixture()
      assert %Ecto.Changeset{} = Activities.change_activity_record(activity_record)
    end
  end
end
