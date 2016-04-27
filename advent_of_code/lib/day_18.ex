defmodule Day18 do
  @input_file "data/day_18.txt"
  @on ?#
  @off ?.

  @moduledoc """
  The state a light should have next is based on its current state (on or
  off) plus the number of neighbors that are on:

  - A light which is on stays on when 2 or 3 neighbors are on, and turns off
    otherwise.

  - A light which is off turns on if exactly 3 neighbors are on, and stays
    off otherwise.

  - All of the lights update simultaneously; they all consider the same
    current state before moving to the next.

  A board is a list of char lists.
  """
  def run(steps \\ 100, input_file \\ @input_file) do
    life(steps, input_file, &life_rules/5)
  end

  @doc """
  Four corner lights are stuck.

      iex> Day18.stuck_lights(5, "test.txt")
      17
  """
  def stuck_lights(steps \\ 100, input_file \\ @input_file) do
    life(steps, input_file, &stuck_life_rules/5)
  end

  def life(steps, input_file, cell_rules) do
    cells = read_board(input_file)
    board = {cells, cells |> length, cells |> hd |> length}

    {final_cells, _, _} = (1..steps)
    |> Enum.reduce(board, fn _, b -> next_board(b, cell_rules) end)

    final_cells
    |> List.flatten
    |> Enum.filter(fn c -> c == @on end)
    |> length
  end

  defp read_board(input_file) do
    File.stream!(input_file)
    |> Enum.map(&read_board_line/1)
  end

  defp read_board_line(line) do
    line
    |> String.strip
    |> String.to_char_list
  end

  defp next_board({_, rows, cols} = board, cell_rules) do
    cells = for row <- (0..rows-1),
        col <- (0..cols-1) do
      next_state(board, row, col, cell_rules)
    end
    |> Enum.chunk(cols)
    {cells, rows, cols}
  end

  defp next_state(board, row, col, cell_rules) do
    state = at(board, row, col)
    number_on_neighbors = neighbors_of(board, row, col)
    |> Enum.filter(&(&1 == @on))
    |> length
    cell_rules.(board, row, col, state, number_on_neighbors)
  end

  defp life_rules(_, _, _, state, number_on_neighbors) do
    case {state, number_on_neighbors} do
      {@on, 2} -> @on
      {@on, 3} -> @on
      {@off, 3} -> @on
      _ -> @off
    end
  end

  defp stuck_life_rules({_, rows, cols}, row, col, _, _)
  when (row == 0 and col == 0) or
       (row == 0 and col == cols-1) or
       (row == rows-1 and col == 0) or
       (row == rows-1 and col == cols-1) do
    @on
  end
  defp stuck_life_rules(_, _, _, state, number_on_neighbors) do
    life_rules(nil, nil, nil, state, number_on_neighbors)
  end

  defp at({_, rows, cols}, row, col) when row < 0 or col < 0 or row >= rows or col >= cols, do: nil
  defp at({cells, _, _}, row, col) do
    cells
    |> Enum.drop(row)
    |> hd
    |> Enum.drop(col)
    |> hd
  end

  def neighbors_of(board, row, col) do
    [at(board, row-1, col-1),
     at(board, row-1, col),
     at(board, row-1, col+1),
     at(board, row, col-1),
     at(board, row, col+1),
     at(board, row+1, col-1),
     at(board, row+1, col),
     at(board, row+1, col+1)]
  end
end

# Day18.run(4, "test.txt")
# #=> 814

# Day18.stuck_lights
# #=> 861 is too low
