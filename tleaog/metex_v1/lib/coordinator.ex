defmodule Metex.Coordinator do
  
  @moduledoc """
  Coordinates requests/responses to Metex.Workers.
  """

  def loop(results \\ [], n)

  def loop(results, results_expected) when results_expected < 1 do
    IO.puts(results |> Enum.sort |> Enum.join(", "))
  end
  def loop(results, results_expected) do
    receive do
      {:ok, result} ->
        loop([result | results], results_expected-1)
      _ ->
        loop(results, results_expected)
    end
  end
end
