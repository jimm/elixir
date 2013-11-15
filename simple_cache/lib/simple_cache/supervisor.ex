defmodule SimpleCache.Supervisor do
  use Supervisor.Behaviour

  @server __MODULE__

  def start_link do
    :supervisor.start_link({:local, @server}, __MODULE__, [])
  end

  def init(_options) do
    children = [supervisor(SimpleCache.ElementSupervisor, []),
                worker(SimpleCache.Event, [])]
    supervise(children, strategy: :one_for_one, max_restarts: 40, max_seconds: 3600)
  end
end
