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

  # Will it help to work backwards? Start with longest substitutions?
  def e_to_medicine(input_file \\ @input_file) do
    {replacements, medicine} = parse(input_file)
    reverse_replacements = replacements |> Enum.map(fn [k,v] -> [v,k] end)
    by_length = reverse_replacements |> Enum.group_by(fn [k,_] -> String.length(k) end)
    IO.puts "starting length of medicine = #{String.length(medicine)}"
    reduce_to_e(medicine, by_length, by_length |> Map.keys |> Enum.max, 0)
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

  # ================ reduction ================

  def reduce_to_e("e", _, _, num_steps) do
    IO.puts "**************** ding ding ding ****************"
    IO.puts "num steps = #{num_steps}"
  end
  def reduce_to_e(s, mappings, 0, num_steps) do
    IO.puts "reduced to this pass = #{s}"
    IO.puts "num steps = #{num_steps}"
    reduce_to_e(s, mappings, mappings |> Map.keys |> Enum.max, num_steps)
  end
  def reduce_to_e(s, mappings, len, num_steps) do
    len_mappings = Map.get(mappings, len, [])
    [reduced, count] = len_mappings |> Enum.reduce([s, 0], fn [long, short], [s, steps] ->
      [count, s] = replace_and_count(s, long, short, 0)
      [s, steps + count]
    end)
    reduce_to_e(reduced, mappings, len-1, num_steps+count)
  end

  def replace_and_count(s, old, new, count) do
    replaced = String.replace(s, old, new, global: false)
    if replaced == s do
      [count, s]
    else
      replace_and_count(replaced, old, new, count+1)
    end
  end
end

# Day19.single_sub_uniq_count
# => 576 too low
