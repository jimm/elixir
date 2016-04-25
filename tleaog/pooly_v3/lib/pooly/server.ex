defmodule Pooly.Server do

  @moduledoc """
  State:

  * `:sup` - This server's supervisor pid
  * `:worker_sup` - Worker supervisor pid
  * `:config` - Pooly.Config
  * `:workers` - List of workers
  * `:monitors` - ETS table that holds monitors' `{worker, monitor_ref}`
  tuples
  """

  use GenServer
  import Supervisor.Spec

  # ================ API ================

  def start_link(pools_config) do
    GenServer.start_link(__MODULE__, pools_config, name: __MODULE__)
  end

  def checkout(pool_name) do
    GenServer.call(:"#{pool_name}Server", :checkout)
  end

  def checkin(pool_name, worker_pid) do
    GenServer.cast(:"#{pool_name}Server", {:checkin, worker_pid})
  end

  def status(pool_name) do
    GenServer.call(:"#{pool_name}Server", :status)
  end

  # ================ Callbacks ================

  def init(pools_config) do
    pools_config |> Enum.each(&(send(self, {:start_pool, &1})))
    {:ok, pools_config}
  end

  def handle_info({:start_pool, pool_config}, state) do
    {:ok, _pool_sup} = Supervisor.start_child(Pooly.PoolsSupervisor,
      supervisor_spec(pool_config))
    {:no_reply, state}
  end

  # ================ Private Functions ================

  defp supervisor_spec(pool_config) do
    opts = [id: :"#{pool_config.name}Supervisor"]
    supervisor(Pooly.PoolSupervisor, [pool_config], opts)
  end
end
