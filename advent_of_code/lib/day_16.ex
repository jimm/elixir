defmodule Day16 do
  @input_file "data/day_16.txt"
  @parse_regex ~r{Sue (\d+): (\w+): (\d+), (\w+): (\d+), (\w+): (\d+)}
  @analysis %{
    children: 3,
    cats: 7,
    samoyeds: 2,
    pomeranians: 3,
    akitas: 0,
    vizslas: 0,
    goldfish: 5,
    trees: 3,
    cars: 2,
    perfumes: 1,
  }

  def run(matcher) do
    File.stream!(@input_file)
    |> Enum.map(&parse/1)
    |> Enum.drop_while(&(!matcher.(&1)))
    |> Enum.take(1)
    |> hd
    |> Map.get(:num)
  end

  defp parse(line) do
    [nstr | attrs] = Regex.run(@parse_regex, line) |> tl
    Enum.reduce(attrs |> Enum.chunk(2),
      %{num: String.to_integer(nstr)},
      fn([attr, nstr], acc) -> Map.put(acc, String.to_atom(attr), String.to_integer(nstr)) end)
  end

  def match1(sue) do
    num_matches = sue
    |> Map.keys
    |> Enum.drop_while(fn
      :num -> true
      k -> Map.get(@analysis, k) == Map.get(sue, k)
    end)
    |> length

    num_matches == 0
  end

  def updated_retroencabulator_match(sue) do
    num_matches = sue
    |> Map.keys
    |> Enum.drop_while(fn
      :num -> true
      :cats -> Map.get(@analysis, :cats) < Map.get(sue, :cats)
      :trees -> Map.get(@analysis, :trees) < Map.get(sue, :trees)
      :pomeranians -> Map.get(@analysis, :pomeranians) > Map.get(sue, :pomeranians)
      :goldfish -> Map.get(@analysis, :goldfish) > Map.get(sue, :goldfish)
      k -> Map.get(@analysis, k) == Map.get(sue, k)
    end)
    |> length

    num_matches == 0
  end
end

# Day16.run(&Day16.match1/1)
# #=> 103

# Day16.run(&Day16.updated_retroencabulator_match/1)
# #=> 405
