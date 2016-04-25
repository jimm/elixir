defmodule Pooly.PoolSupervisor do
  use Supervisor

  def start_link(pool_config) do
    Supervisor.start_link(__MODULE__, pool_config, name: :"{pool_config.name}Supervisor")
  end

  def init(pool_config) do
    children = [
      worker(Pooly.PoolServer, [self, pool_config])
    ]
    opts = [strategy: :one_for_all]
    supervise(children, opts)
  end
  
end
