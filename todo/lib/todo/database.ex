defmodule Todo.Database do
  def start_link do
    IO.puts("Starting database.")
  end

  def child_spec(_) do
    File.mkdir_p!(db_dir())

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: db_pool_size()
      ],
      [db_dir()]
    )
  end

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.store(worker_pid, key, data)
      end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.get(worker_pid, key)
      end
    )
  end

  def delete(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.delete(worker_pid, key)
      end
    )
  end

  defp db_dir() do
    Application.fetch_env!(:todo, :db_dir)
  end

  defp db_pool_size() do
    Application.fetch_env!(:todo, :db_pool_size)
  end
end
