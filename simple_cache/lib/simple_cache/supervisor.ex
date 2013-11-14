defmodule SimpleCache.Supervisor do
  use Supervisor.Behaviour

  @server __MODULE__

  def start_link do
    :supervisor.start_link({:local, @server}, __MODULE__, [])
  end

  def start_child(value, lease_time) do
    :supervisor.start_child(@server, [value, lease_time])
  end

  def init(_options) do
    prototype = worker(SimpleCache.Element, [], restart: :temporary, shutdown: :brutal_kill)
    supervise([prototype], strategy: :simple_one_for_one, max_restarts: 0, max_seconds: 1)
  end
end
