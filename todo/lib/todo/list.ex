defmodule Todo.List do
  defstruct next_id: 1, entries: %{}

  @doc """
  Returns a new Todo list.

  ## Examples:

      iex> Todo.List.new()
      %Todo.List{next_id: 1, entries: %{}}

      iex> Todo.List.new([%{foo: "bar"}])
      %Todo.List{next_id: 2, entries: %{1 => %{id: 1, foo: "bar"}}}
  """
  def new(entries \\ []) do
    Enum.reduce(entries, %__MODULE__{}, &add_entry(&2, &1))
  end

  @doc """
  Adds an entry to `todo_list`.

  ## Examples:

      iex> Todo.List.new() |> Todo.List.add_entry(%{foo: "bar"}) |> Todo.List.add_entry(%{foo: 42})
      %Todo.List{next_id: 3, entries: %{1 => %{id: 1, foo: "bar"}, 2 => %{id: 2, foo: 42}}}
  """
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.next_id,
        entry
      )

    %__MODULE__{
      entries: new_entries,
      next_id: todo_list.next_id + 1
    }
  end

  @doc """
  Updates the entry with `id` in `todo_list` by calling `updater_fun` on the
  existing value. If there is no entry with the given `id`, the original
  todo list is returned unchanged.

  ## Examples:

      iex> Todo.List.new() |>
      iex> Todo.List.add_entry(%{foo: 42}) |>
      iex> Todo.List.update_entry(1, fn e -> Map.put(e, :digits, Integer.digits(e[:foo])) end)
      %Todo.List{next_id: 2, entries: %{1 => %{id: 1, foo: 42, digits: [4, 2]}}}
  """
  def update_entry(%__MODULE__{entries: entries} = todo_list, entry_id, updater_fun) do
    case Map.fetch(entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %__MODULE__{todo_list | entries: new_entries}
    end
  end

  @doc """
  Deletes entry at `entry_id`. No error is raised if there is no such entry.

  ## Examples:

      iex> Todo.List.new([%{foo: 42}]) |> Todo.List.delete_entry(1)
      %Todo.List{next_id: 2, entries: %{}}

      iex> Todo.List.new([%{foo: 42}]) |> Todo.List.delete_entry(99)
      %Todo.List{next_id: 2, entries: %{1 => %{id: 1, foo: 42}}}
  """
  def delete_entry(%__MODULE__{entries: entries} = todo_list, entry_id) do
    {_, new_entries} = Map.pop(entries, entry_id)
    %__MODULE__{todo_list | entries: new_entries}
  end

  @doc """
  Returns a list of all the entries with date `date`.

  ## Examples

      iex> Todo.List.new([%{date: ~D[2026-01-01], title: "NYE Party"}]) |>
      iex> Todo.List.entries(~D[2026-01-01])
      [%{id: 1, date: ~D[2026-01-01], title: "NYE Party"}]

      iex> Todo.List.new() |> Todo.List.entries(~D[2026-01-01])
      []
  """
  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end
end
