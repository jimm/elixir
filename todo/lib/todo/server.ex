defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.minutes(10)

  # ==== Initialization

  def start_link(name) do
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end

  @impl GenServer
  def init(todo_list_name) do
    IO.puts("Starting server for #{todo_list_name}.")

    {
      :ok,
      # initial state
      {todo_list_name, nil},
      # read data later; see handle_continue below
      {:continue, :init}
    }
  end

  # ==== Public interface

  def add_entry(server, entry) do
    GenServer.cast(server, {:add_entry, entry})
  end

  def update_entry(server, entry_id, updater_fn) do
    GenServer.cast(server, {:update_entry, entry_id, updater_fn})
  end

  def delete_entry(server, entry_id) do
    GenServer.cast(server, {:delete_entry, entry_id})
  end

  def entries(server, date) do
    GenServer.call(server, {:entries, self(), date})
  end

  # ==== GenServer handlers

  @impl GenServer
  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:udpate_entry, entry_id, updater_fn}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry_id, updater_fn)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:entries, _, date}, _, {_, todo_list} = state) do
    {:reply, Todo.List.entries(todo_list, date), state, @expiry_idle_timeout}
  end

  # Called async during process initialization. Since getting the db
  # contents might be expensive, we do that here instead of in `init/1`.
  @impl GenServer
  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}, @expiry_idle_timeout}
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
