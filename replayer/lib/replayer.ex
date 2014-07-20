defmodule Replayer do

  alias Replayer.LogParser, as: LP
  alias Replayer.Client, as: C

  def run(file, server) do
    first_line = File.stream!(file) |> Stream.take(1) |> Enum.to_list |> hd
    first_request_time = LP.parse(first_line).time

    requests = File.stream!(file)
      |> Stream.map(&LP.parse/1)
      |> Enum.sort(&(&2.time > &1.time))
      |> Enum.chunk_by(&(&1.time))

    now = :calendar.universal_time()
    me = self()
    tasks = requests
      |> Enum.flat_map(fn(list) ->
                         list
                           |> Stream.with_index
                           |> Stream.map(&C.make_request(me, server, &1, now,
                                                         first_request_time))
                       end)
      wait_for_completion(Enum.count(tasks))
  end

  defp wait_for_completion(count) when count <= 0, do: nil

  defp wait_for_completion(count) do
    receive do
      {:code, url, code} ->
        case code do
          200 -> nil            # yay
          c -> IO.puts "status #{code} returned by URL #{url}"
        end
      {:error, url, %HTTPotion.HTTPError{message: msg}} ->
        IO.puts "error: #{msg}; url: #{url}"
      {:error, url, error} ->
        IO.puts "error: #{inspect error}; url: #{url}"
    end
    wait_for_completion(count-1)
  end
end
