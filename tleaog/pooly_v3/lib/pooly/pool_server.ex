defmodule Pooly.PoolServer do

  @moduledoc """
  State:

  * `:pool_sup` - This server's supervisor pid
  * `:worker_sup` - Worker supervisor pid
  * `:config` - Pooly.Config
  * `:workers` - List of workers
  * `:monitors` - ETS table that holds monitors' {worker, monitor_ref} tuples
  * `:size` - Pool size
  """

  use GenServer
  import Supervisor.Spec

  defmodule State do
    defstruct pool_sup: nil, worker_sup: nil, monitors: nil, size: nil,
      workers: nil, name: nil, config: nil
  end

  # ================ API ================

  def start_link(pool_sup, pool_config) do
    GenServer.start_link(__MODULE__, [pool_sup, pool_config], name: name(pool_config.name))
  end

  def checkout(pool_name) do
    GenServer.call(name(pool_name), :checkout)
  end

  def checkin(pool_name, worker_pid) do
    GenServer.cast(name(pool_name), {:checkin, worker_pid})
  end

  @doc """
  Returns a tuple containing the number of workers (pool size) and the
  number of active workers.
  """
  def status(pool_name) do
    GenServer.call(name(pool_name), :status)
  end

  # ================ Callbacks ================

  def init([pool_sup, pool_config]) do
    Process.flag(:trap_exit, true)
    monitors = :ets.new(:monitors, [:private])
    state = %State{pool_sup: pool_sup, worker_sup: nil, monitors: monitors,
                   size: pool_config.size, workers: nil, name: pool_config.name,
                   config: pool_config}
    send(self, :start_worker_supervisor)
    {:ok, state}
  end

  def handle_info(:start_worker_supervisor, %{pool_sup: pool_sup, config: config} = state) do
    mfa = {config.module, config.function, config.args}
    {:ok, worker_sup} = Supervisor.start_child(pool_sup, supervisor_spec(config.name, mfa))
    workers = prepopulate(config.size, worker_sup)
    {:noreply, %{state | worker_sup: worker_sup, workers: workers}}
  end

  def handle_call(:checkout, {from_pid, _ref},
                  %{workers: workers, monitors: monitors} = state) do
    case workers do
      [worker | rest] ->
        ref = Process.monitor(from_pid)
        true = :ets.insert(monitors, {worker, ref})
        {:reply, worker, %{state | workers: rest}}
      [] ->
        {:reply, :noproc, state}
    end
  end

  def handle_call(:status, _from,
                  %{workers: workers, monitors: monitors} = state) do
    {:reply, {length(workers), :ets.info(monitors, :size)}, state}
  end

  def handle_cast({:checkin, worker},
                  %{workers: workers, monitors: monitors} = state) do
    case :ets.lookup(monitors, worker) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        {:no_reply, %{state | workers: [pid | workers]}}
      [] ->
        {:_noreply, state}
    end
  end

  def handle_info({:DOWN, ref, _, _, _},
        state = %{monitors: monitors, workers: workers}) do
    case :ets.match(monitors, {:"$1", ref}) do
      [[pid]] ->
        true = :ets.delete(monitors, pid)
        new_state = %{state | workers: [pid|workers]}
        {:no_reply, new_state}
      [[]] ->
        {:no_reply, state}
    end
  end

  def handle_info({:EXIT, pid, _reason}, state = %{monitors: monitors, workers:
                                                   workers, pool_sup: pool_sup}) do
    case :ets.lookup(monitors, pid) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        new_state = %{state | workers: [new_worker(pool_sup)|workers]}
        {:no_reply, new_state}
      _ ->
        {:no_reply, state}
    end
  end

  def handle_info({:EXIT, worker_sup, reason}, state = %{worker_sup: worker_sup}) do
    {:stop, reason, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  # ================ Private Functions ================

  defp name(pool_name), do: :"#{pool_name}Server"

  defp supervisor_spec(name, config) do
	  opts = [id: name <> "WorkerSupervisor", restart: :temporary]
    supervisor(Pooly.WorkerSupervisor, [self, config], opts)
  end

  defp prepopulate(size, sup), do: prepopulate(size, sup, [])

  defp prepopulate(size, _, workers) when size < 1, do: workers
  defp prepopulate(size, sup, workers) do
    prepopulate(size-1, sup, [new_worker(sup) | workers])
  end

  defp new_worker(sup) do
	  {:ok, worker} = Supervisor.start_child(sup, [[]])
    worker
  end
end
