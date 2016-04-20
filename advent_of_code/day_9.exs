#!/usr/bin/env elixir

defmodule Day9 do
  @input_file "day_9.txt"

  def shortest, do: run(&Enum.min/1)

  def longest, do: run(&Enum.max/1)

  def run(f) do
    distances = File.stream!(@input_file)
    |> Enum.reduce(%{}, fn line, acc ->
      [src, "to", dest, "=", num_str] = String.split(line)
      dist = String.to_integer(num_str)
      acc
      |> add_distance(src, dest, dist)
      |> add_distance(dest, src, dist)
    end)

    f.(path_lengths(distances, permutations(Map.keys(distances)), []))
  end

  defp add_distance(m, src, dest, dist) do
    distances = Map.get(m, src, %{})
    Map.put(m, src, Map.put(distances, dest, dist))
  end

  defp permutations([]), do: []
  defp permutations([x]), do: [x]
  defp permutations([x, y]), do: [[x, y], [y, x]]
  defp permutations(xs) do
    for x <- xs,
        y <- permutations(List.delete(xs, x)) do
      [x | y]
    end
  end

  defp path_lengths(_, [], lengths), do: lengths
  defp path_lengths(distances, [path | paths], lengths) do
    path_lengths(distances, paths, [path_length(distances, path) | lengths])
  end

  defp path_length(distances, path) do
    path
    |> Enum.chunk(2, 1)
    |> Enum.map(fn [src, dest] -> distances[src][dest] end)
    |> Enum.sum
  end
end

IO.inspect Day9.shortest
# => 251

IO.inspect Day9.longest
# => 898
