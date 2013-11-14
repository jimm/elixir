defmodule SimpleCache.Element do

  use GenServer.Behaviour

  @default_lease_time 60 * 60 * 24

  defrecord State, value: nil, lease_time: 0, start_time: 0

  # ================ API ================
  
  def start_link(value, lease_time) do
    :gen_server.start_link(__MODULE__, [value, lease_time], [])
  end

  def create(value, lease_time) do
    SimpleCache.Supervisor.start_child(value, lease_time)
  end

  def create(value) do
    create(value, @default_lease_time)
  end

  def fetch(pid) do
    :gen_server.call(pid, :fetch)
  end

  def replace(pid, value) do
    :gen_server.cast(pid, {:replace, value})
  end

  def delete(pid) do
    :gen_server.cast(pid, :delete)
  end

  # ================ GenServer ================

  def init([value, lease_time]) do
    now = :calendar.local_time()
    start_time = :calendar.datetime_to_gregorian_seconds(now)
    {:ok, State[value: value, lease_time: lease_time, start_time: start_time], time_left(start_time, lease_time)}
  end

  defp time_left(_start_time, :infinity) do
    :infinity
  end
  defp time_left(start_time, lease_time) do
    now = :calendar.local_time()
    curr_time = :calendar.datetime_to_gregorian_seconds(now)
    time_elapsed = curr_time - start_time
    case lease_time - time_elapsed do
      time when time <= 0 -> 0
      time -> time * 1000       # milliseconds
    end
    time
  end

  def handle_call(:fetch, _from, state) do
    time_left = time_left(state.start_time, state.lease_time)
    {:reply, {:ok, state.value}, state, time_left}
  end

  def handle_cast({:replace, value}, state) do
    time_left = time_left(state.start_time, state.lease_time)
    {:noreply, {:ok, state.value(value)}, time_left}
  end

  def handle_cast(:delete, state) do
    {:stop, :normal, state}
  end

  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  def terminate(_reason, _state) do
    SimpleCache.Store.delete(self())
    :ok
  end

end
