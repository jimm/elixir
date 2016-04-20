defmodule Day1 do
  @input_file "data/day_1.txt"

  def destination_floor do
    File.read!(@input_file)
    |> String.codepoints
    |> Enum.reduce(0, fn(c, acc) -> acc + move(c) end)
  end

  def first_basement_index do
    File.read!(@input_file)
    |> String.codepoints
    |> first_negative_one(0, 0)
  end

  defp move(c) when c == "(", do: 1
  defp move(c) when c == ")", do: -1

  defp first_negative_one(_, -1, index), do: index
  defp first_negative_one([], _, _), do: raise "not found"
  defp first_negative_one([c|rest], floor, index) when c == "(" do
    first_negative_one(rest, floor+1, index+1)
  end
  defp first_negative_one([c|rest], floor, index) do
    first_negative_one(rest, floor-1, index+1)
  end
end

# Day1.destination_floor
# Day1.first_basement_index
