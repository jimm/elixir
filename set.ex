defmodule Set do
  @moduledoc """
  Set permutation.
  """

  @doc """
  N things taken N at a time.
  """
  def permutations(xs), do: permutations(xs, length(xs))

  @doc """
  N things taken K at a time.
  """
  def permutations([], _), do: []
  def permutations(xs, 1), do: xs |> Enum.map(&([&1]))
  def permutations(xs, k) do
    for x <- xs,
        y <- permutations(List.delete(xs, x), k-1) do
      [x | y]
    end
  end
end
