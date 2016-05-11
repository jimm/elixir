defmodule Blitzy do
  def start(_type, _args) do
    Blitzy.Supervisor.start_link(:ok)
  end

  def run(num_workers, url) when num_workers > 0 do
    worker_fun = fn -> Blitzy.worker.start(url) end
    1..num_workers
    |> Enum.map(fn _ -> Task.async(worker_fun) end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> parse_results
  end

  defp parse_results(results) do
    {success, _failures} =
      results
      |> Enum.partition(fn x ->
           case x do
             {:ok, _} -> true
             _ -> false
           end
         end)
    total_workers = length(results)
    total_success = length(success)
    total_failure = total_workers - total_success

    data = successes |> Enum.map(fn {:ok, time} -> time end)
    average_time = average(data)
    {shortest_time, longest_time} = Enum.min_max(data)

    IO.puts """
    Total workers    : #{total_workers}
    Successful reqs  : #{total_success}
    Failed res       : #{total_failure}
    Average (msecs)  : #{average_time}
    Longest (msecs)  : #{longest_time}
    Shortest (msecs) : #{shortest_time}
    """
  end

  defp average([]), do: 0
  defp average(list) do
    Enum.sum(list) / length(list)
  end
end
