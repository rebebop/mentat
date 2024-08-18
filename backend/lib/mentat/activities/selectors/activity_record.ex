defmodule Mentat.Activities.Selectors.ActivityRecord do
  import Ecto.Query, warn: false

  alias Mentat.Activities.ActivityRecord

  def get_activity_records_by_date_range(user_id, date_range, where_clause) do
    {start_date, end_date} = date_range

    query =
      from a in ActivityRecord,
        where: a.user_id == ^user_id,
        where: ^where_clause,
        where: fragment("date_trunc('day', ?) between ? and ?", a.logged_at, ^start_date, ^end_date)

    Repo.all(query)
  end
end
