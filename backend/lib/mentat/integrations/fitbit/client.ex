defmodule Mentat.Integrations.Fitbit.Client do
  alias Mentat.Activities
  alias Mentat.Integrations.Fitbit.AuthStrategy

  def get_sleep_data(user_id) do
    result = AuthStrategy.api_request(user_id, :get, "hrv/date/2024-08-08.json")
    IO.inspect(result)
  end

  def save_heartrate_variability(user_id, provider_id, date) do
    {start_date, end_date} = start_and_end_of_day(date)
    {:ok, response} = AuthStrategy.api_request(user_id, :get, "hrv/date/#{date}.json")

    value =
      response.body |> Map.get("hrv") |> Enum.at(0) |> Map.get("value") |> Map.get("dailyRmssd")

    Activities.save_activity_record(user_id, %{
      value: value,
      start_time: start_date,
      end_time: end_date,
      measuring_scale: :heartrate_variability,
      provider_id: provider_id
    })
  end

  def start_and_end_of_day(date_string) do
    {:ok, date} = Date.from_iso8601(date_string)
    start_of_day = DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
    end_of_day = DateTime.new!(date, ~T[23:59:59.999999], "Etc/UTC")
    {start_of_day, end_of_day}
  end
end
