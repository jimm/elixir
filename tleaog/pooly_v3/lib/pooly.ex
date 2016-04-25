defmodule Pooly do
  use Application
  alias Pooly.{Config, Supervisor, Server, SampleWorker}

  def start(_type, _args) do
    pools_config = [
      %Config{name: "Pool1", module: SampleWorker, function: :start_link,
              args: [], size: 2},
      %Config{name: "Pool2", module: SampleWorker, function: :start_link,
              args: [], size: 3},
      %Config{name: "Pool3", module: SampleWorker, function: :start_link,
              args: [], size: 4},
    ]
    start_pools(pools_config)
  end

  def start_pools(pools_config), do: Supervisor.start_link(pools_config)

  def checkout(pool_name), do: Server.checkout(pool_name)

  def checkin(pool_name, worker_pid), do: Server.checkin(pool_name, worker_pid)

  def status(pool_name), do: Server.status(pool_name)
end
