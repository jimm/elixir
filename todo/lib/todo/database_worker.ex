defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}) do
    GenServer.start(__MODULE__, {db_folder, worker_id}, name: via_tuple(worker_id))
  end

  @impl GenServer
  def init({db_folder, worker_id}) do
    IO.puts("Starting database worker #{worker_id}.")
    {:ok, db_folder}
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  def delete(worker_id, key) do
    GenServer.cast(via_tuple(worker_id), {:delete, key})
  end

  @impl GenServer
  def handle_cast({:store, key, data}, db_folder) do
    key
    |> file_name(db_folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  @impl GenServer
  def handle_cast({:delete, key}, db_folder) do
    case key |> file_name(db_folder) |> File.rm() do
      :ok ->
        {:noreply, db_folder}

      {:error, :enoent} ->
        {:noreply, db_folder}

      # TODO log error
      {:error, _reason} ->
        {:noreply, db_folder}
    end
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_folder) do
    data =
      case key |> file_name(db_folder) |> File.read() do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, db_folder}
  end

  defp file_name(key, db_folder) do
    Path.join(db_folder, to_string(key))
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end
end
