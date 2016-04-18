#!/usr/bin/env elixir

defmodule Day5 do
  @input_file "day_5.txt"
  @forbidden ~r{(ab)|(cd)|(pq)|(xy)}
  @doubled ~r{(.)\1}
  @three_vowels ~r{[aeiou].*[aeiou].*[aeiou]}
  @pairs_doubled ~r{(..).*\1}
  @repeat_one_between ~r{(.).\1}

  def count_nice(f) do
    File.stream!(@input_file)
    |> Stream.map(&String.strip/1)
    |> Stream.filter(fn(s) -> f.(s) end)
    |> Enum.to_list
    |> length
  end

  def nice1(s) do
    !Regex.match?(@forbidden, s) &&
      Regex.match?(@doubled, s) &&
      Regex.match?(@three_vowels, s)
  end

  def nice2(s) do
    Regex.match?(@pairs_doubled, s) &&
      Regex.match?(@repeat_one_between, s)
  end
end

IO.inspect Day5.count_nice(&Day5.nice1/1)
IO.inspect Day5.count_nice(&Day5.nice2/1)
