#!/usr/bin/env elixir

defmodule Test do
  def permutations([]), do: []
  def permutations([x]), do: [x]
  def permutations([x, y]), do: [[x, y], [y, x]]
  def permutations(xs) do
    for x <- xs,
        y <- permutations(List.delete(xs, x)) do
      [x | y]
    end
  end
end

IO.inspect Test.permutations([1, 2, 3, 4])
