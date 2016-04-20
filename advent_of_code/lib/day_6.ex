defmodule Day6 do
  @input_file "data/day_6.txt"
  @line_nums ~r{(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)}
  @num_rows 1000
  @row_len 1000

  def count_lights do
    sum_after_applying(%{
      "turn on" => fn(_) -> 1 end,
      "turn off" => fn(_) -> 0 end,
      "toggle" => fn(brightness) -> 1 - brightness end
    })
  end

  def total_brightness do
    sum_after_applying(%{
      "turn on" => fn(brightness) -> brightness + 1 end,
      "turn off" => fn
          (0) -> 0
          (1) -> 0
          (brightness) -> brightness - 1
        end,
      "toggle" => fn(brightness) -> brightness + 2 end
    })
  end

  def sum_after_applying(funcmap) do
    grid = List.duplicate(0, @num_rows * @row_len) |> Enum.chunk(@row_len)
    File.stream!(@input_file)
    |> Enum.map(&(parse(&1, funcmap)))
    |> Enum.reduce(grid, fn(cmd, lights) -> execute(lights, cmd) end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sum
  end

  defp parse(s, funcmap) do
    [_ | [cmd | num_strs]] = Regex.run(@line_nums, s)
    [x0, y0, x1, y1] = num_strs |> Enum.map(&String.to_integer/1)
    {funcmap[cmd], min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1)}
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

# Day6.count_lights
# => 377891

# Day6.total_brightness
# # => 14110788
