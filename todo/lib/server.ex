defmodule Todo.Server do
  use GenServer

  # ==== Initialization

  def start do
    GenServer.start(__MODULE__, nil)
  end

  @impl GenServer
  def init(_), do: {:ok, Todo.List.new()}

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
  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end

  def handle_cast({:udpate_entry, entry_id, updater_fn}, todo_list) do
    {:noreply, Todo.List.update_entry(todo_list, entry_id, updater_fn)}
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, Todo.List.delete_entry(todo_list, entry_id)}
  end

  @impl GenServer
  def handle_call({:entries, _, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end
end
