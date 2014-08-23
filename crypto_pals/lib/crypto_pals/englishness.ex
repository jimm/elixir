defmodule CryptoPals.Englishness do

  @relative_freqs [
    {?e, 13}, {?t, 9}, {?a, 8}, {?o, 8}, {?i, 7}, {?n, 7},
    {?s,  6}, {?h, 6}, {?r, 6}, {?d, 4}, {?l, 4}, {?c, 3},
    {?u,  3}, {?m, 2}, {?w, 2}, {?f, 2}, {?g, 2}, {?y, 2},
    {?p,  2}, {?b, 2}, {?v, 1}, {?k, 1}, {?j, 1}, {?x, 1},
    {?q, 1}, {?z, 1}
  ]

  @doc """
  Calculate a number that determines how likely that the given string is
  english text. Higher numbers are better. Letters get two points plus a
  bonus for how popular they are ("etaion shrdlu"); whitespace, punctuation,
  and numbers get one.

  ## Examples

      iex> CryptoPals.Englishness.englishness("abc")
      19/3
      iex> CryptoPals.Englishness.englishness("ABC")
      19/3
      iex> CryptoPals.Englishness.englishness("a?")
      11/2
      iex> CryptoPals.Englishness.englishness("This is a test. Fun? Yes!")
      161/25
      iex> CryptoPals.Englishness.englishness("Level 42")
      48/8
      iex> CryptoPals.Englishness.englishness("thê")
      18/3

  """
  def englishness(s), do: englishness(s, {String.length(s), 0})

  defp englishness(<<>>, {slen, sum}), do: sum / slen
  defp englishness(<<c :: utf8, t :: binary>>, {slen, sum}) when c in ?a .. ?z do
    englishness(t, {slen, sum + 2 + freq_bonus(c)})
  end
  defp englishness(<<c :: utf8, t :: binary>>, {slen, sum}) when c in ?A .. ?Z do
    englishness(t, {slen, sum + 2 + freq_bonus(c - ?A + ?a)})
  end
  defp englishness(<<c :: utf8, t :: binary>>, {slen, sum})
    when c == ?\s or
      c in ?0 .. ?9 or
      c in [?., ?,, ?!, ??, ?;, ?;, ?(, ?)] \
  do
    englishness(t, {slen, sum + 1})
  end
  defp englishness(<<_ :: utf8, t :: binary>>, {slen, sum}), do: englishness(t, {slen, sum-1})

  defp freq_bonus(c) do
    {_, freq} = List.keyfind(@relative_freqs, c, 0, 0)
    freq
  end
end
