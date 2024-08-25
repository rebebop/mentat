defmodule Mentat.Integrations.Fitbit.Client do
  require Logger
  alias Mentat.Activities
  alias Mentat.Integrations.Fitbit.FitbitActivities
  alias Mentat.Integrations.Fitbit.AuthStrategy

  def sync(user_id, provider_id) do
    end_date = DateTime.new!(Date.utc_today(), ~T[00:00:00])

    client_state = %{
      user_id: user_id,
      provider_id: provider_id,
      end_date: end_date,
      start_date: DateTime.shift(end_date, day: -30)
    }

    save_heartrate_variability(client_state)
    save_sleep(client_state)
    save_workout(client_state)
  end

  def save_workout(state) do
    value_fn = &(&1 / 60000)
    # TODO: use the actviity list to get all the ids that corresponds to workouts and then filter for them

    "activities/list.json?afterDate=#{get_day_string(state.start_date)}&offset=0&limit=50&sort=asc"
    |> AuthStrategy.api_request(state.user_id, :get)
    |> case do
      {:ok, response} ->
        workout_ids = FitbitActivities.get_all_workout_ids()

        get_values_from_response(response, "activities")
        |> Enum.filter(fn a -> a["activityTypeId"] in workout_ids end)
        |> process_response(state, :workout_min, &get_in(&1, ["activeDuration"]), "startTime", value_fn)

      {:error, err} ->
        Logger.error(
          "Could not save activity log data from provider :fitbit for user:#{state.user_id}\n #{inspect(err, pretty: true)}"
        )
    end
  end

  def save_heartrate_variability(state) do
    date_range_api_url("hrv", state.start_date, state.end_date)
    |> AuthStrategy.api_request(state.user_id, :get)
    |> case do
      {:ok, response} ->
        get_values_from_response(response, "hrv")
        |> process_response(state, :heartrate_variability, &get_in(&1, ["value", "dailyRmssd"]), "dateTime")

      {:error, _} ->
        Logger.error("Could not save heartrate variability data from provider :fitbit for user:#{state.user_id}")
    end
  end

  def save_sleep(state) do
    date_range_api_url("sleep", state.start_date, state.end_date)
    |> AuthStrategy.api_request(state.user_id, :get, 1.2)
    |> case do
      {:ok, response} ->
        sleep_response = get_values_from_response(response, "sleep")

        save_sleep_min(sleep_response, state)
        save_sleep_deep_min(sleep_response, state)
        save_sleep_light_min(sleep_response, state)
        save_sleep_rem_min(sleep_response, state)
        save_sleep_awake_min(sleep_response, state)
        save_sleep_awakenings(sleep_response, state)

      {:error, _} ->
        Logger.error("Could not save sleep data from provider fitbit for user:#{state.user_id}")
    end
  end

  defp save_sleep_min(sleep_response, state) do
    value_path = &get_in(&1, ["duration"])
    value_fn = &(&1 / 60000)

    process_response(sleep_response, state, :sleep_min, value_path, "dateOfSleep", value_fn)
  end

  defp save_sleep_deep_min(sleep_response, state) do
    value_path = &get_in(&1, ["levels", "summary", "deep", "minutes"])

    process_response(sleep_response, state, :sleep_deep_min, value_path, "dateOfSleep")
  end

  defp save_sleep_light_min(sleep_response, state) do
    value_path = &get_in(&1, ["levels", "summary", "light", "minutes"])

    process_response(sleep_response, state, :sleep_light_min, value_path, "dateOfSleep")
  end

  defp save_sleep_rem_min(sleep_response, state) do
    value_path = &get_in(&1, ["levels", "summary", "rem", "minutes"])

    process_response(sleep_response, state, :sleep_rem_min, value_path, "dateOfSleep")
  end

  defp save_sleep_awake_min(sleep_response, state) do
    value_path =
      &(get_in(&1, ["levels", "summary", "awake", "minutes"]) || get_in(&1, ["levels", "summary", "wake", "minutes"]))

    process_response(sleep_response, state, :sleep_awake_min, value_path, "dateOfSleep")
  end

  defp save_sleep_awakenings(sleep_response, state) do
    value_path =
      &(get_in(&1, ["levels", "summary", "awake", "count"]) || get_in(&1, ["levels", "summary", "wake", "count"]))

    process_response(sleep_response, state, :sleep_awakenings, value_path, "dateOfSleep")
  end

  defp process_response(response, state, attribute, value_path, date_path, value_fn \\ & &1) do
    response
    |> Enum.reduce([], fn response, records ->
      date_time = response[date_path]
      value = value_path.(response) |> value_fn.()

      [build_new_record(state, date_time, value, attribute) | records]
    end)
    |> filter_previous_records(state, attribute)
    |> Activities.save_or_update_activity_records()
  end

  defp get_day_string(datetime), do: Calendar.strftime(datetime, "%Y-%m-%d")

  defp date_range_api_url(entity, start_date, end_date),
    do: "#{entity}/date/#{get_day_string(start_date)}/#{get_day_string(end_date)}.json"

  defp get_previous_records(state, attribute) do
    where_clause = [provider_id: state.provider_id, attribute: attribute]

    Activities.get_activity_records_by_date_range(
      state.user_id,
      {state.start_date, state.end_date},
      where_clause
    )
  end

  defp get_values_from_response(response, response_key), do: response.body |> Map.get(response_key)

  defp build_new_record(state, date_time, value, attribute) do
    %{
      user_id: state.user_id,
      value: value,
      logged_at: parse_fitbit_date_time(date_time),
      attribute: attribute,
      provider_id: state.provider_id
    }
  end

  defp parse_fitbit_date_time(date_str) do
    case DateTime.from_iso8601(date_str) do
      {:ok, date_time, _} -> date_time |> DateTime.truncate(:second)
      {:error, _} -> DateTime.new!(Date.from_iso8601!(date_str), ~T[00:00:00])
    end
  end

  defp filter_previous_records(records, state, attribute) do
    previous_records = get_previous_records(state, attribute)
    filter_previous_records(records, state, attribute, previous_records)
  end

  defp filter_previous_records(records, _state, _attribute, []), do: records

  defp filter_previous_records(records, _state, _attribute, previous_records) do
    records
    |> Enum.filter(fn record -> !Enum.find(previous_records, &(&1.logged_at == record.logged_at)) end)
  end
end
