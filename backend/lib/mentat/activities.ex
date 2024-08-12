defmodule Mentat.Activities do
  import Ecto.Query, warn: false
  alias Mentat.Repo

  alias Mentat.Activities.ActivityRecord

  def save_activity_record(user_id, attrs) do
    %ActivityRecord{user_id: user_id}
    |> ActivityRecord.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of activity_records.

  ## Examples

      iex> list_activity_records()
      [%ActivityRecord{}, ...]

  """
  def list_activity_records do
    Repo.all(ActivityRecord)
  end

  @doc """
  Gets a single activity_record.

  Raises `Ecto.NoResultsError` if the Activity record does not exist.

  ## Examples

      iex> get_activity_record!(123)
      %ActivityRecord{}

      iex> get_activity_record!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity_record!(id), do: Repo.get!(ActivityRecord, id)

  @doc """
  Creates a activity_record.

  ## Examples

      iex> create_activity_record(%{field: value})
      {:ok, %ActivityRecord{}}

      iex> create_activity_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity_record(attrs \\ %{}) do
    %ActivityRecord{}
    |> ActivityRecord.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a activity_record.

  ## Examples

      iex> update_activity_record(activity_record, %{field: new_value})
      {:ok, %ActivityRecord{}}

      iex> update_activity_record(activity_record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity_record(%ActivityRecord{} = activity_record, attrs) do
    activity_record
    |> ActivityRecord.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a activity_record.

  ## Examples

      iex> delete_activity_record(activity_record)
      {:ok, %ActivityRecord{}}

      iex> delete_activity_record(activity_record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity_record(%ActivityRecord{} = activity_record) do
    Repo.delete(activity_record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity_record changes.

  ## Examples

      iex> change_activity_record(activity_record)
      %Ecto.Changeset{data: %ActivityRecord{}}

  """
  def change_activity_record(%ActivityRecord{} = activity_record, attrs \\ %{}) do
    ActivityRecord.changeset(activity_record, attrs)
  end
end
