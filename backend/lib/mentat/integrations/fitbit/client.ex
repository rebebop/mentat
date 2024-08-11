defmodule Mentat.Integrations.Fitbit.Client do
  alias Mentat.Integrations.Fitbit.AuthStrategy

  def get_sleep_data(user_id) do
    result = AuthStrategy.api_request(user_id, :get, "hrv/date/2024-08-08.json")
    IO.inspect(result)
  end
end
