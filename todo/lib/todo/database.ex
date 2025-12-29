defmodule Todo.Database do
  use GenServer

  @db_folder "./todo-persist"
  @num_workers 3

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)

    workers =
      0..(@num_workers - 1)
      |> Enum.reduce(%{}, fn i, workers ->
        {:ok, worker} = Todo.DatabaseWorker.start(@db_folder)
        Map.put(workers, i, worker)
      end)

    {:ok, workers}
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  @impl GenServer
  def handle_cast({:store, key, data}, workers) do
    key
    |> choose_worker(workers)
    |> Todo.DatabaseWorker.store(key, data)

    {:noreply, workers}
  end

  @impl GenServer
  def handle_cast({:delete, key}, workers) do
    key
    |> choose_worker(workers)
    |> Todo.DatabaseWorker.delete(key)

    {:noreply, workers}
  end

  @impl GenServer
  def handle_call({:get, key}, _, workers) do
    data =
      key
      |> choose_worker(workers)
      |> Todo.DatabaseWorker.get(key)

    {:reply, data, workers}
  end

  defp choose_worker(key, workers) do
    Map.get(workers, :erlang.phash2(key, @num_workers))
  end
end
