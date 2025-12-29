defmodule Todo.Database do
  use GenServer

  @db_folder "./todo-persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, nil}
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

  def handle_cast({:store, key, data}, state) do
    key
    |> file_name()
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    case key |> file_name |> File.rm() do
      :ok ->
        {:noreply, state}

      {:error, :enoent} ->
        {:noreply, state}

      # TODO log error
      {:error, _reason} ->
        {:noreply, state}
    end
  end

  def handle_call({:get, key}, _, state) do
    data =
      case File.read(file_name(key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
