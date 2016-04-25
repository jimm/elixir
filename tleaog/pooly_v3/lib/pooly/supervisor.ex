defmodule Pooly.Supervisor do
  use Supervisor
  
  @moduledoc """
  Top-level supervisor for Pooly.
  """

  def start_link(pools_config) do
  Supervisor.start_link(__MODULE__, pools_config, name: __MODULE__)
  end

  def init(pools_config) do
    children = [
      supervisor(Pooly.PoolsSupervisor, []),
      worker(Pooly.Server, [self, pools_config])
    ]
    opts = [strategy: :one_for_all]
    supervise(children, opts)
  end
end
