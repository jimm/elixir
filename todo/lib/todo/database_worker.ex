defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  def init(db_folder) do
    {:ok, db_folder}
  end

  def store(worker, key, data) do
    GenServer.cast(worker, {:store, key, data})
  end

  def get(worker, key) do
    GenServer.call(worker, {:get, key})
  end

  def delete(worker, key) do
    GenServer.cast(worker, {:delete, key})
  end

  def handle_cast({:store, key, data}, db_folder) do
    key
    |> file_name(db_folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

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
end
