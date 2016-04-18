#!/usr/bin/env elixir

defmodule Day7 do
  @input_file "day_7.txt"

  use Bitwise

  def run do
    code = File.stream!(@input_file)
      |> Enum.map(&transpile/1)
      |> reorder
      |> Enum.concat([quote do a_ end]) # return a_ at end to get result
      |> IO.inspect

    {answer, _} = Code.eval_quoted(code, [], __ENV__)
    answer
  end

  defp transpile(s) when is_binary(s) do
    s |> String.split |> transpile
  end
  defp transpile(["NOT", var, "->", target]) do
    quote do
      unquote(safe(target)) = bnot(unquote(safe(var))) &&& 0xffff
    end
  end
  defp transpile([var1, "AND", var2, "->", target]) do
    quote do
      unquote(safe(target)) = unquote(safe(var1)) &&& unquote(safe(var2))
    end
  end
  defp transpile([var1, "OR", var2, "->", target]) do
    quote do
      unquote(safe(target)) = bor(unquote(safe(var1)), unquote(safe(var2)))
    end
  end
  defp transpile([var1, "LSHIFT", var2, "->", target]) do
    quote do
      unquote(safe(target)) = bsl(unquote(safe(var1)), unquote(safe(var2))) &&& 0xffff
    end
  end
  defp transpile([var1, "RSHIFT", var2, "->", target]) do
    quote do
      unquote(safe(target)) = bsr(unquote(safe(var1)), unquote(safe(var2)))
    end
  end
  defp transpile([value, "->", target]) do
    quote do
      unquote(safe(target)) = unquote(safe(value))
    end
  end

  # Appends "_" to non-numeric strings so we don't have to worry about
  # reserved words.
  defp safe(<<c>> <> _ = s) when c >= ?0 and c <= ?9, do: s
  defp safe(s), do: "#{s}_"

  # FIXME
  defp reorder(statements) do
    statements
  end
end

IO.inspect Day7.run
