defmodule Day3 do
  @input_file "data/day_3.txt"

  require Integer

  def received_present_count do
    File.read!(@input_file)
    |> String.codepoints
    |> locs_and_counts
    |> Map.keys
    |> length
  end

  def santa_plus_robo_present_count do
    directions_with_indexes = File.read!(@input_file)
      |> String.codepoints
      |> Enum.with_index

    {odd_dirs_and_indexes, even_dirs_and_indexes} = directions_with_indexes
      |> Enum.partition(fn({_, idx}) -> Integer.is_odd(idx) end)

    odd_dirs = odd_dirs_and_indexes |> Enum.map(fn({dir, _}) -> dir end)
    even_dirs = even_dirs_and_indexes |> Enum.map(fn({dir, _}) -> dir end)

    (odd_dirs |> locs_and_counts)
    |> Map.merge(even_dirs |> locs_and_counts)
    |> Map.keys
    |> length
  end

  defp locs_and_counts(directions) do
    {_, counts} = directions
      |> Enum.reduce({{0, 0}, %{{0, 0} => 1}}, fn(c, {curr_pos, counts}) ->
        new_pos = move(curr_pos, c)
        {new_pos, Map.update(counts, new_pos, 1, &(&1+1))}
      end)

    counts
  end

  defp move({x, y}, c) when c == "^", do: {x, y+1}
  defp move({x, y}, c) when c == ">", do: {x+1, y}
  defp move({x, y}, c) when c == "v", do: {x, y-1}
  defp move({x, y}, c) when c == "<", do: {x-1, y}
end

# Day3.received_present_count
# Day3.santa_plus_robo_present_count
