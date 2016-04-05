defmodule Pooly.Server do

  @moduledoc """
  State:

  * `:sup` - This server's supervisor pid
  * `:worker_sup` - Worker supervisor pid
  * `:config` - Pooly.Config
  * `:workers` - List of workers
  * `:monitors` - ETS table that holds monitors' {worker, monitor_ref} tuples
  """

  use GenServer
  import Supervisor.Spec

  # ================ API ================

  def start_link(sup, pool_config) do
    GenServer.start_link(__MODULE__, [sup, pool_config], name: __MODULE__)
  end

  def checkout do
    GenServer.call(__MODULE__, :checkout)
  end

  def checkin(worker_pid) do
    GenServer.cast(__MODULE__, {:checkin, worker_pid})
  end

  @doc """
  Returns a tuple containing the number of workers (pool size) and the
  number of active workers.
  """
  def status do
    GenServer.call(__MODULE__, status)
  end

  # ================ Callbacks ================

  def init([sup, pool_config]) do
    monitors = :ets.new(:monitors, [:private])
    send(self, :start_worker_supervisor)
    {:ok, %{sup: sup, config: pool_config, monitors: monitors,
            worker_sup: nil, workers: []}}
  end

  def handle_info(:start_worker_supervisor, %{sup: sup, config: config} = state) do
    mfa = {config.module, config.function, config.args}
    {:ok, worker_sup} = Supervisor.start_child(sup, supervisor_spec(mfa))
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

  # ================ Private Functions ================

  defp supervisor_spec(config) do
	  opts = [restart: :temporary]
    supervisor(Pooly.WorkerSupervisor, [config], opts)
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
