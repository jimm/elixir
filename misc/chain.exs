# iex chain.exs
# > Chain.run(100_000)

# Creates N processes chained together and use them. Note that there's a
# system-wide max number of processes, which can be overridden on the
# command line.
defmodule Chain do
  def counter(next_pid) do
    receive do
      n -> send(next_pid, n + 1)
    end
  end

  # Creates a chain of N processes and returns the last one. They are
  # chained together by their spawned calls to `counter`.
  def create_processes(n) do
    last =
      Enum.reduce(1..n, self(), fn _, send_to ->
        spawn(Chain, :counter, [send_to])
      end)

    # start the count by sending 0
    send(last, 0)

    # wait for result
    receive do
      final_answer -> "Result is #{inspect(final_answer)}"
    end
  end

  # Creates N processes, each of which receives an integer message and sends
  # that number + 1 to the next process in the chain. Returns the last value
  # (i.e. the number of processes).
  def run(n) do
    IO.puts(inspect(:timer.tc(Chain, :create_processes, [n])))
  end
end

# Or, to get number of processes from the command line:

# {_, [n_str | _], _} = OptionParser.parse(System.argv(), strict: [])
# Chain.run(String.to_integer(n_str))
