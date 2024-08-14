defmodule Mentat.Integrations.Fitbit.Client do
  require Logger
  alias Mentat.Activities
  alias Mentat.Integrations.Fitbit.AuthStrategy

  def sync(user_id, provider_id) do
    {:ok, end_date} = DateTime.new(Date.utc_today(), ~T[00:00:00])
    start_date = DateTime.shift(end_date, day: -30)

    # save_heartrate_variability(user_id, provider_id, start_date, end_date)
    save_sleep(user_id, provider_id, start_date, end_date)
  end

  def save_heartrate_variability(user_id, provider_id, start_date, end_date) do
    date_range_api_url("hrv", start_date, end_date)
    |> AuthStrategy.api_request(user_id, :get)
    |> case do
      {:ok, response} ->
        previous_records =
          Activities.get_activity_records_by_date_range(
            user_id,
            provider_id,
            :heartrate_variability,
            {start_date, end_date},
            :only_match_day
          )

        response.body
        |> Map.get("hrv")
        |> Enum.each(fn hrv ->
          hrv_date_time = hrv["dateTime"]
          hrv_value = hrv["value"]["dailyRmssd"]

          existing_record? =
            Enum.find(previous_records, fn record -> get_day_string(record.start_time) == hrv_date_time end)

          if existing_record? do
            Activities.update_activity_record(existing_record?, %{value: hrv_value})
          else
            hrv_date_time_obj = Date.from_iso8601!(hrv_date_time)

            Activities.save_activity_record(user_id, %{
              value: hrv_value,
              start_time: DateTime.new!(hrv_date_time_obj, ~T[00:00:00]),
              end_time: DateTime.new!(hrv_date_time_obj, ~T[23:59:59]),
              measuring_scale: :heartrate_variability,
              provider_id: provider_id
            })
          end
        end)

      {:error, _} ->
        Logger.error("Could not save heartrate variability data from provider :fitbit for user:#{user_id}")
    end
  end

  def save_sleep(user_id, provider_id, start_date, end_date) do
    date_range_api_url("sleep", start_date, end_date)
    |> AuthStrategy.api_request(user_id, :get, 1.2)
    |> case do
      {:ok, response} ->
        sleep_response = response.body |> Map.get("sleep")
        save_sleep_min(user_id, provider_id, start_date, end_date, sleep_response)
        save_sleep_deep_min(user_id, provider_id, start_date, end_date, sleep_response)
        save_sleep_light_min(user_id, provider_id, start_date, end_date, sleep_response)
        save_sleep_rem_min(user_id, provider_id, start_date, end_date, sleep_response)
        save_sleep_awake_min(user_id, provider_id, start_date, end_date, sleep_response)
        save_sleep_awakenings(user_id, provider_id, start_date, end_date, sleep_response)

      {:error, _} ->
        Logger.error("Could not save sleep data from provider fitbit for user:#{user_id}")
    end
  end

  defp get_day_string(datetime), do: Calendar.strftime(datetime, "%Y-%m-%d")

  defp date_range_api_url(entity, start_date, end_date),
    do: "#{entity}/date/#{get_day_string(start_date)}/#{get_day_string(end_date)}.json"

  defp save_sleep_min(user_id, provider_id, start_date, end_date, sleep_response) do
    previous_records =
      Activities.get_activity_records_by_date_range(
        user_id,
        provider_id,
        :sleep_min,
        {start_date, end_date},
        :only_match_day
      )

    sleep_response
    |> Enum.each(fn sleep ->
      date_time = sleep["dateOfSleep"]
      # milliseconds to minutes
      duration = sleep["duration"] / 60000

      record_exists? = Enum.find(previous_records, fn record -> get_day_string(record.start_time) == date_time end)

      if record_exists? do
        Activities.update_activity_record(record_exists?, %{value: duration})
      else
        sleep_date_time_obj = Date.from_iso8601!(date_time)

        Activities.save_activity_record(user_id, %{
          value: duration,
          start_time: DateTime.new!(sleep_date_time_obj, ~T[00:00:00]),
          end_time: DateTime.new!(sleep_date_time_obj, ~T[23:59:59]),
          measuring_scale: :sleep_min,
          provider_id: provider_id
        })
      end
    end)
  end

  defp save_sleep_deep_min(user_id, provider_id, start_date, end_date, sleep_response) do
    previous_records =
      Activities.get_activity_records_by_date_range(
        user_id,
        provider_id,
        :sleep_deep_min,
        {start_date, end_date},
        :only_match_day
      )

    sleep_response
    |> Enum.each(fn sleep ->
      date_time = sleep["dateOfSleep"]
      deep_sleep_duration = get_in(sleep, ["levels", "summary", "deep", "minutes"])

      if deep_sleep_duration do
        record_exists? = Enum.find(previous_records, fn record -> get_day_string(record.start_time) == date_time end)

        if record_exists? do
          Activities.update_activity_record(record_exists?, %{value: deep_sleep_duration})
        else
          date_time_obj = Date.from_iso8601!(date_time)

          Activities.save_activity_record(user_id, %{
            value: deep_sleep_duration,
            start_time: DateTime.new!(date_time_obj, ~T[00:00:00]),
            end_time: DateTime.new!(date_time_obj, ~T[23:59:59]),
            measuring_scale: :sleep_deep_min,
            provider_id: provider_id
          })
        end
      end
    end)
  end

  defp save_sleep_light_min(user_id, provider_id, start_date, end_date, sleep_response) do
    previous_records =
      Activities.get_activity_records_by_date_range(
        user_id,
        provider_id,
        :sleep_light_min,
        {start_date, end_date},
        :only_match_day
      )

    sleep_response
    |> Enum.each(fn sleep ->
      date_time = sleep["dateOfSleep"]
      duration = get_in(sleep, ["levels", "summary", "light", "minutes"])

      if duration do
        record_exists? = Enum.find(previous_records, fn record -> get_day_string(record.start_time) == date_time end)

        if record_exists? do
          Activities.update_activity_record(record_exists?, %{value: duration})
        else
          date_time_obj = Date.from_iso8601!(date_time)

          Activities.save_activity_record(user_id, %{
            value: duration,
            start_time: DateTime.new!(date_time_obj, ~T[00:00:00]),
            end_time: DateTime.new!(date_time_obj, ~T[23:59:59]),
            measuring_scale: :sleep_light_min,
            provider_id: provider_id
          })
        end
      end
    end)
  end

  defp save_sleep_rem_min(user_id, provider_id, start_date, end_date, sleep_response) do
    previous_records =
      Activities.get_activity_records_by_date_range(
        user_id,
        provider_id,
        :sleep_rem_min,
        {start_date, end_date},
        :only_match_day
      )

    sleep_response
    |> Enum.each(fn sleep ->
      date_time = sleep["dateOfSleep"]
      duration = get_in(sleep, ["levels", "summary", "rem", "minutes"])

      if duration do
        record_exists? = Enum.find(previous_records, fn record -> get_day_string(record.start_time) == date_time end)

        if record_exists? do
          Activities.update_activity_record(record_exists?, %{value: duration})
        else
          date_time_obj = Date.from_iso8601!(date_time)

          Activities.save_activity_record(user_id, %{
            value: duration,
            start_time: DateTime.new!(date_time_obj, ~T[00:00:00]),
            end_time: DateTime.new!(date_time_obj, ~T[23:59:59]),
            measuring_scale: :sleep_rem_min,
            provider_id: provider_id
          })
        end
      end
    end)
  end

  defp save_sleep_awake_min(user_id, provider_id, start_date, end_date, sleep_response) do
    previous_records =
      Activities.get_activity_records_by_date_range(
        user_id,
        provider_id,
        :sleep_awake_min,
        {start_date, end_date},
        :only_match_day
      )

    sleep_response
    |> Enum.each(fn sleep ->
      date_time = sleep["dateOfSleep"]

      duration =
        get_in(sleep, ["levels", "summary", "awake", "minutes"]) ||
          get_in(sleep, ["levels", "summary", "wake", "minutes"])

      if duration do
        record_exists? = Enum.find(previous_records, fn record -> get_day_string(record.start_time) == date_time end)

        if record_exists? do
          Activities.update_activity_record(record_exists?, %{value: duration})
        else
          date_time_obj = Date.from_iso8601!(date_time)

          Activities.save_activity_record(user_id, %{
            value: duration,
            start_time: DateTime.new!(date_time_obj, ~T[00:00:00]),
            end_time: DateTime.new!(date_time_obj, ~T[23:59:59]),
            measuring_scale: :sleep_awake_min,
            provider_id: provider_id
          })
        end
      end
    end)
  end

  defp save_sleep_awakenings(user_id, provider_id, start_date, end_date, sleep_response) do
    previous_records =
      Activities.get_activity_records_by_date_range(
        user_id,
        provider_id,
        :sleep_awakenings,
        {start_date, end_date},
        :only_match_day
      )

    sleep_response
    |> Enum.each(fn sleep ->
      date_time = sleep["dateOfSleep"]

      count =
        get_in(sleep, ["levels", "summary", "awake", "count"]) || get_in(sleep, ["levels", "summary", "wake", "count"])

      if count do
        record_exists? = Enum.find(previous_records, fn record -> get_day_string(record.start_time) == date_time end)

        if record_exists? do
          Activities.update_activity_record(record_exists?, %{value: count})
        else
          date_time_obj = Date.from_iso8601!(date_time)

          Activities.save_activity_record(user_id, %{
            value: count,
            start_time: DateTime.new!(date_time_obj, ~T[00:00:00]),
            end_time: DateTime.new!(date_time_obj, ~T[23:59:59]),
            measuring_scale: :sleep_awakenings,
            provider_id: provider_id
          })
        end
      end
    end)
  end
end
