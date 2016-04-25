defmodule Set do
  @moduledoc """
  Set permutation.
  """

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
