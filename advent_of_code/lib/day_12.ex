defmodule Day12 do
  @input_file "data/day_12.txt"
  @number_regex ~r{(-?[\d]+)}
  @red_json_object_regex ~r/{[^}]*"red"[^}]*\}/

  def sum do
    File.read!(@input_file)
    |> collect_numbers
    |> Enum.sum
  end

  def non_red_sum do
    File.read!(@input_file)
    |> collect_non_red_numbers
    |> Enum.sum
  end

  defp collect_numbers(s) do
    Regex.scan(@number_regex, s)
    |> Enum.map(fn [_, num] -> String.to_integer(num) end)
  end

  defp collect_non_red_numbers(s) do
    {:ok, m} = Poison.decode(s)
    m
    |> non_red_numbers
    |> List.flatten
  end

  defp non_red_numbers(m) when is_map(m) do
    vals = Map.values(m)
    if Enum.member?(vals, "red") do
      []
    else
      vals
      |> IO.inspect
      |> Enum.map(&non_red_numbers/1)
    end
  end
  defp non_red_numbers(l) when is_list(l) do
    l |> Enum.map(&non_red_numbers/1)
  end
  defp non_red_numbers(val) when is_integer(val), do: val
  defp non_red_numbers(_), do: []

  defp numbers_in([], acc), do: acc
  defp numbers_in([h|t], acc) when is_integer(h) do
    numbers_in(t, [h|acc])
  end
  defp numbers_in([_|t], acc) do
    numbers_in(t, acc)
  end
end

# Day12.sum
# # => 119433

# Day12.non_red_sum
# # => 68466
