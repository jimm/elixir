defmodule Day4 do
  @key "iwrupvqb"

  def mine_coin do
    Stream.iterate(1, &(&1+1))
    |> Stream.map(fn(i) -> {i, hash("#{@key}#{i}")} end)
    |> Stream.drop_while(fn {_, h} -> bad_hash(h) end)
    |> Enum.take(1)
  end

  defp hash(s) do
    :crypto.hash(:md5, s)
  end

  # three
  # defp good_hash(<<0, 0, n>> <> _rest) when n < 16, do: true

  # six
  defp good_hash(<<0, 0, 0>> <> _rest), do: true
  defp good_hash(_), do: false

  defp bad_hash(bin), do: !good_hash(bin)
end

# Day4.mine_coin
