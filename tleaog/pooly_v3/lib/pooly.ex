defmodule Pooly do
  use Application
  alias Pooly.{Config, Supervisor, Server, SampleWorker}

  def start(_type, _args) do
    pool_config = %Config{module: SampleWorker,
                          function: :start_link,
                          args: [],
                          size: 5}
    start_pool(pool_config)
  end

  def start_pool(pool_config), do: Supervisor.start_link(pool_config)

  def checkout, do: Server.checkout

  def checkin(worker_pid), do: Server.checkin(worker_pid)

  def status, do: Server.status
end
