defmodule Stack.Server do
  use GenServer

  # ================ interface ================

  def start_link(stack) do
    GenServer.start_link(__MODULE__, stack, name: __MODULE__)
  end

  def push(val), do: GenServer.cast(__MODULE__, {:push, val})

  def pop, do: GenServer.call(__MODULE__, :pop)

  def peek, do: GenServer.call(__MODULE__, :peek)

  def empty?, do: GenServer.call(__MODULE__, :empty?)

  # ================ server ================

  def handle_cast({:push, val}, stack) do
    {:noreply, [val|stack]}
  end

  def handle_call(:pop, _from, [h|t]) do
    {:reply, h, t}
  end

  def handle_call(:peek, _from, [h|_] = stack) do
    {:reply, h, stack}
  end

  def handle_call(:empty?, _from, []) do
    {:reply, true, []}
  end
  def handle_call(:empty?, _from, stack) do
    {:reply, false, stack}
  end

  def terminate(reason, state) do
    IO.puts "#{__MODULE__}.terminate called"
    IO.puts "reason = #{inspect reason}"
    IO.puts "state = #{inspect state}"
  end
end
