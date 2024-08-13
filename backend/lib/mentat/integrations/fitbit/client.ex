defmodule Mentat.Integrations.Fitbit.Client do
  alias Mentat.Activities
  alias Mentat.Integrations.Fitbit.AuthStrategy

  def sync(user_id, provider_id) do
    {:ok, end_date} = DateTime.new(Date.utc_today(), ~T[00:00:00])
    start_date = DateTime.shift(end_date, day: -30)

    save_heartrate_variability(user_id, provider_id, start_date, end_date)
  end

  def get_sleep_data(user_id) do
    result = AuthStrategy.api_request(user_id, :get, "hrv/date/2024-08-08.json")
    IO.inspect(result)
  end

  def save_heartrate_variability(user_id, provider_id, start_date, end_date) do
    {:ok, response} =
      AuthStrategy.api_request(
        user_id,
        :get,
        "hrv/date/#{get_day_string(start_date)}/#{get_day_string(end_date)}.json"
      )

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
        Enum.find(previous_records, fn record ->
          get_day_string(record.start_time) == hrv_date_time
        end)

      {:ok, s_date} = Date.from_iso8601(hrv_date_time)

      if existing_record? do
        Activities.update_activity_record(existing_record?, %{value: hrv_value})
      else
        {:ok, s_date} = Date.from_iso8601(hrv_date_time)

        Activities.save_activity_record(user_id, %{
          value: hrv_value,
          start_time: DateTime.new!(s_date, ~T[00:00:00]),
          end_time: DateTime.new!(s_date, ~T[23:59:59]),
          measuring_scale: :heartrate_variability,
          provider_id: provider_id
        })
      end
    end)
  end

  defp get_day_string(datetime), do: Calendar.strftime(datetime, "%Y-%m-%d")
end
