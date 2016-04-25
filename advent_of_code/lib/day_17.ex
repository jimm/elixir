defmodule Day17 do
  @input_file "test.txt"
  @liters 25
  # @input_file "data/day_17.txt"
  # @liters 150

  def run do
    container_sizes = File.stream!(@input_file) |> Enum.map(&(&1 |> String.strip |> String.to_integer))
    IO.inspect container_sizes
  end
end

# Day17.run
# =>

# The elves bought too much eggnog again - 150 liters this time. To fit it
# all into your refrigerator, you'll need to move it into smaller
# containers. You take an inventory of the capacities of the available
# containers.

# For example, suppose you have containers of size 20, 15, 10, 5, and 5
# liters. If you need to store 25 liters, there are four ways to do it:

# 15 and 10
# 20 and 5 (the first 5)
# 20 and 5 (the second 5)
# 15, 5, and 5
#
# Filling all containers entirely, how many different combinations of
# containers can exactly fit all 150 liters of eggnog?