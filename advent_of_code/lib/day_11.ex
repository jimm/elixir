defmodule Day11 do
  @start "hepxcrrq"
  @illegal_chars_regex ~r/[iol]/
  @two_pair_regex ~r/(.)\1.*(.)\2/

  def next_good_password(nth \\ 1) do
    good_passwords
    |> Enum.take(nth)
    |> Enum.reverse
    |> hd
  end

  defp good_passwords do
    Stream.repeatedly(fn -> 1 end)
    |> Stream.transform(@start, fn(_, acc) -> {[acc], next(acc)} end)
    |> Stream.filter(fn pwd -> good?(pwd) end)
  end

  defp next(pwd) do
    pwd
    |> String.to_char_list
    |> increment_char_list
    |> to_string
  end

  defp increment_char_list(cl) do
    increment = &(&1+1)
    cl
    |> Enum.map(&(&1 - ?a))
    |> Integer.undigits(26)
    |> increment.()
    |> Integer.digits(26)
    |> Enum.map(&(&1 + ?a))
  end

  defp good?(pwd) do
    run_of_three?(pwd) && !illegal_chars?(pwd) && two_pairs?(pwd)
  end

  defp run_of_three?(pwd) do
    run_of_three?(pwd |> String.to_char_list, 0)
  end

  defp run_of_three?(_, 2), do: true
  defp run_of_three?([], _), do: false
  defp run_of_three?([_], _), do: false
  defp run_of_three?([c1|[c2|_]=rest], consec_count) do
    if c2 == c1+1 do
      run_of_three?(rest, consec_count+1)
    else
      run_of_three?(rest, 0)
    end
  end

  defp illegal_chars?(pwd) do
    Regex.match?(@illegal_chars_regex, pwd)
  end

  defp two_pairs?(pwd) do
    case Regex.run(@two_pair_regex, pwd) do
      [_, m1, m2] -> m1 != m2
      nil -> false
    end
  end
end

# Day11.next_good_password
# # => hepxxyzz

# Day11.next_good_password(2)
# # => heqaabcc
