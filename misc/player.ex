defmodule Player do

  @doc """
Need a supervisor that can kill all scheduled future events.

Given a collection of {time, data} pairs and a function, runs the function
with the data at that time. Time values must be milliseconds and be relative
to the start of the sequence.

Returns a supervisor. Send :stop to the supervisor to stop all future
events.

See also the Erlang :calendar.now_to_* functions
"""

  def play(time_pairs, f) do
    time_pairs
    |> Enum.map(fn({t,d}) -> Task.async(at_time_run(t, d, f)) end)
    |> Enum.map(&Task.await/1)
    # loop(time_pairs, f)
  end

  def at_time_run(time, data, f) do
    IO.puts("setting up time #{time}, data #{data}, f #{inspect f}") # DEBUG
    Process.send_after(self(), {:call, data, f}, time)
    IO.puts("Process.send_after called, waiting for response") # DEBUG
    receive do
      {:call, data, f} ->
        f.(data)
    end
  end

  # def loop([], _), do: :ok
  # def loop([{0, data}|t], f) do
  #   spawn(fn -> f.(data) end)
  #   loop(t, f)
  # end
  # def loop([{time, data}|t], f) do
  #   Process.send_after(self(), {:call, data, f}, time)
  #   receive do
  #     {:call, data, f} ->
  #       spawn(fn -> f.(data) end)
  #       loop(t, f)
  #   end
  # end

  def test do
    [{0, "immediately"},
     {0, "again, immediately"},
     {1000, "after one second"},
     {1000, "after another second"},
     {500, "after 1/2 second"},
     {0, "alongside 1/2 second wait"},
     {1000, "done"}]
    |> play(fn(data) ->
      IO.puts "#{inspect :os.timestamp()}: #{data}"
    end)
  end

end
