defmodule Day19 do
  @input_file "data/day_19.txt"

  def single_sub_uniq_count(input_file \\ @input_file) do
    {replacements, start} = parse(input_file)
    replacements |> Enum.map(fn [key, val] ->
      start |> String.split(key) |> make_subs(key, val)
    end)
    |> List.flatten
    |> Enum.uniq
    |> length
  end

  def e_to_medicine(input_file \\ @input_file) do
    {replacements, medicine} = parse(input_file)
    start = "e"
  end

  def parse(input_file) do
    lines = File.read!(input_file) |> String.split("\n")
    {replacement_lines, end_lines} = lines |> Enum.split(length(lines)-2)
    {replacement_lines |> Enum.map(&String.split(&1, " => ")),
     end_lines |> tl |> hd}
  end

  def make_subs(split_points, key, val) do
    make_subs(split_points, key, val, 1, length(split_points), [])
  end

  # split points after, split points before, val, subs
  def make_subs(_, _, _, len, len, subs), do: subs
  def make_subs(split_points, key, val, n, len, subs) do
    {befores, afters} = Enum.split(split_points, n)
    subbed = ((befores |> Enum.join(key)) <>
      val <>
      (afters |> Enum.join(key)))
    make_subs(split_points, key, val, n+1, len, [subbed | subs])
  end
end

# Day19.single_sub_uniq_count
# => 576 too low
