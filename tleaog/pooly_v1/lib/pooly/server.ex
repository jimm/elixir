defmodule Pooly.Server do
  use GenServer
  import Supervisor.Spec

  # ================ API ================

  def start_link(sup, pool_config) do
    GenServer.start_link(__MODULE__, [sup, pool_config], name: __MODULE__)
  end

  # ================ Callbacks ================

  def init(sup, pool_config) do
    send(self, :start_worker_supervisor)
    {:ok, %{mfa: pool_config.mfa, size: pool_config.size}}
  end

  def handle_info(:start_worker_supervisor, {sup, config} = state) do
    {:ok, worker_sup} = Supervisor.start_child(sup, supervisor_spec(config))
    workers = prepopulate(size, worker_sup)
    {:noreply, %{state | worker_sup: worker_sup, workers: workers}}
  end

  # ================ Private Functions ================

  defp supervvisor_spec(config) do
	  opts = [restart: :temporary]
    supervisor(Pooly.WorkerSupervisor, [config], opts)
  end
end
