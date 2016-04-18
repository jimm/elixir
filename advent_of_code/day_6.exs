#!/usr/bin/env elixir

# 376893 is too low
# 377891 is answer?
# 742498 is too high

defmodule Day6 do
  @input_file "day_6.txt"
  @line_nums ~r{(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)}
  @num_rows 1000
  @row_len 1000

  def count_lights do
    grid = List.duplicate(0, @num_rows * @row_len) |> Enum.chunk(@row_len)
    File.stream!(@input_file)
    |> Enum.map(&parse/1)
    |> Enum.reduce(grid, fn(cmd, lights) -> execute(lights, cmd) end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sum
  end

  defp parse(s) do
    [_ | [cmd | num_strs]] = Regex.run(@line_nums, s)
    [x0, y0, x1, y1] = num_strs |> Enum.map(&String.to_integer/1)
    f = case cmd do
      "turn on" -> fn(_) -> 1 end
      "turn off" -> fn(_) -> 0 end
      "toggle" -> fn(state) -> 1 - state end
    end
    {f, min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1)}
  end

  defp execute(lights, {_, _, y0, _, _} = cmd), do: execute(lights, cmd, y0)

  defp execute(lights, {_, _, _, _, y1}, y) when y > y1, do: lights
  defp execute(lights, {f, x0, _, x1, _} = cmd, y) do
    lights |> update(x0, x1, y, f) |> execute(cmd, y+1)
  end

  defp update(lights, x0, x1, y, f) do
    {rows_above, [row | rows_below]} = lights |> Enum.split(y)
    {cols_before, rest} = row |> Enum.split(x0)
    {cols, cols_after} = rest |> Enum.split(x1-x0+1)

    Enum.concat([rows_above,
                 [Enum.concat([cols_before, cols |> Enum.map(f), cols_after])],
                 rows_below])
  end
end

IO.inspect Day6.count_lights
