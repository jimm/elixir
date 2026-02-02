defmodule SimpleRegistry do
  use GenServer

  @moduledoc """
  A simple process registry that uses GenServer and ETS.
  """

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    {:ok, nil}
  end

  def register(name) do
    Process.link(Process.whereis(__MODULE__))

    if :ets.insert_new(__MODULE__, {name, self()}) do
      :ok
    else
      :error
    end
  end

  @doc """
  Returns the PID registered under `name`, or `nil` if there is no entry.
  """
  def whereis(name) do
    case :ets.lookup(__MODULE__, name) do
      [{^name, pid}] -> pid
      [] -> nil
    end
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, state) do
    :ets.match_delete(__MODULE__, {:_, pid})
    {:noreply, state}
  end
end
