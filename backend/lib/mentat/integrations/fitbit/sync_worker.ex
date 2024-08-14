defmodule Mentat.Integrations.Fitbit.SyncWorker do
  alias Mentat.Integrations.Fitbit
  use Oban.Worker, queue: :provider_syncs, unique: [keys: [:provider]]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id, "provider_id" => provider_id}}) do
    Fitbit.Client.sync(user_id, provider_id)

    # enqueue next job in 6 hours
    %{user_id: user_id, provider_id: provider_id}
    |> Fitbit.SyncWorker.new(schedule_in: 21600)
    |> Oban.insert()

    :ok
  end
end
