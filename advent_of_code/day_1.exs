defmodule Day1 do

  @input_file "day_1.txt"

  def move(c) when c == "(", do: 1
  def move(c) when c == ")", do: -1

  def destination_floor do
    File.read!(@input_file)
    |> String.codepoints
    |> Enum.reduce(0, fn(c, acc) -> acc + move(c) end)
  end

  def first_basement_index do
    File.read!(@input_file)
    |> String.codepoints
  end
end

IO.inspect Day1.destination_floor
