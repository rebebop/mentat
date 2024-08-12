defmodule Mentat.Integrations.Fitbit.SyncWorker do
  alias Mentat.Integrations.Fitbit
  use Oban.Worker, queue: :provider_syncs, unique: [keys: [:provider]]

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"date" => date, "user_id" => user_id, "provider_id" => provider_id} = args
      }) do
    Fitbit.Client.save_heartrate_variability(user_id, provider_id, date)

    # enque next job
    # %{date: DateTime.utc_now(), user_id: user_id, provider: :fitbit}
    # |> Fitbit.SyncWorker.new(schedule_in: 60)
    # |> Oban.insert()

    :ok
  end
end