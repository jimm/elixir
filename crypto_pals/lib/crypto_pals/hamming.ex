defmodule CryptoPals.Hamming do

  use Bitwise
  require Integer

  @doc """
  Calculates the Hamming distance between two strings or char sets.

  ## Examples

      iex> CryptoPals.Hamming.hamming_distance("this is a test", "wokka wokka!!!")
      37
      iex> CryptoPals.Hamming.hamming_distance([1, 2, 3], [1, 2, 2])
      1
  """
  def hamming_distance(s0, s1) when is_binary(s0) and is_binary(s1) do
    hamming_distance(String.to_char_list(s0), String.to_char_list(s1))
  end

  def hamming_distance(s0, s1) when is_list(s0) and is_list(s1) do
    Enum.zip(s0, s1)
      |> Enum.map(fn({c0, c1}) -> c0 ^^^ c1 end)
      |> Enum.map(&count_one_bits/1)
      |> Enum.sum
  end

  # Note: as an optimization, we could create a lookup table in advance for
  # all Unicode code points. As a more realistic optimization for this
  # CryptoPals puzzle set, we could create a lookup table for all 256
  # eight-bit values.

  def count_one_bits(n), do: count_one_bits(n, 0)

  defp count_one_bits(0, acc), do: acc
  defp count_one_bits(n, acc) when Integer.odd?(n), do: count_one_bits(n >>> 1, acc+1)
  defp count_one_bits(n, acc)                     , do: count_one_bits(n >>> 1, acc)

end
