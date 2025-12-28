defmodule Todo.List do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %__MODULE__{}, &add_entry(&2, &1))
  end

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

  def update_entry(%Todo.List{} = todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %__MODULE__{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%Todo.List{} = todo_list, entry_id) do
    {_, new_entries} = Map.pop(todo_list.entries, entry_id)
    %__MODULE__{todo_list | entries: new_entries}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end
end
