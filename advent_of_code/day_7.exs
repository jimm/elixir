#!/usr/bin/env elixir

defmodule Day7 do
  @input_file "day_7.txt"

  use Bitwise

  def run do
    File.stream!(@input_file)
    |> Enum.map(&parse/1)
    |> reorder
    |> Enum.reduce(%{}, &execute/2)
    |> Map.get("a")
  end

  # Given "foo bar -> target" returns ["target", "foo", "bar"]
  def parse(s) do
    [target | ["->" | rest]] = s |> String.split |> Enum.reverse
    [target | Enum.reverse(rest)]
  end

  defp execute([target, "NOT", var], context) do
   context |> Map.put(target, bnot(value_of(context, var)) &&& 0xffff)
  end
  defp execute([target, var1, "AND", var2], context) do
    context |> Map.put(target, value_of(context, var1) &&& value_of(context, var2))
  end
  defp execute([target, var1, "OR", var2], context) do
    context |> Map.put(target, bor(value_of(context, var1), value_of(context, var2)))
  end
  defp execute([target, var1, "LSHIFT", var2], context) do
    context |> Map.put(target, bsl(value_of(context, var1), value_of(context, var2)) &&& 0xffff)
  end
  defp execute([target, var1, "RSHIFT", var2], context) do
    context |> Map.put(target, bsr(value_of(context, var1), value_of(context, var2)))
  end
  defp execute([target, value], context) do
    context |> Map.put(target, value_of(context, value))
  end

  # Appends "_" to non-numeric strings so we don't have to worry about
  # reserved words.
  defp value_of(_, <<c>> <> _ = s) when c >= ?0 and c <= ?9, do: String.to_integer(s)
  defp value_of(context, var), do: Map.get(context, var)

  # Reorders a list of statement lists to eliminate dependencies. Each
  # statement list is of the form
  #
  # - [value, "->", target]
  # - [value, BINOP, value, "->" target]
  # - [NOT, value, "->" target]
  defp reorder(statements) do
    dependencies = statements
    |> Enum.reduce(%{}, fn
      ([target, value], m) -> 
        m |> add_dependency(target, value)
      ([target, "NOT", value], m) ->
        m |> add_dependency(target, value)
      ([target, value1, _, value2], m) ->
        m |> add_dependency(target, value1) |> add_dependency(target, value2)
    end)

    reorder(statements, dependencies |> Map.to_list, [])
  end

  defp add_dependency(m, target, value) do
    if variable?(value) do
      Map.put(m, target, [value | Map.get(m, target, [])])
    else
      Map.put_new(m, target, [])
    end
  end

  defp variable?(<<c>> <> _) when c >= ?0 and c <= ?9, do: false
  defp variable?(_), do: true

  defp reorder([], [], reordered), do: Enum.reverse(reordered)
  defp reorder(statements, dependencies, reordered) do
    free_targets = dependencies
    |> Enum.filter(fn
      {_, []} -> true
      _ -> false
    end)
    |> Enum.map(fn {k, _} -> k end)

    {nd_statements, d_statements} = statements
    |> Enum.partition(fn([target | _]) -> Enum.member?(free_targets, target) end)

    reorder(d_statements,
            remove_satisfied_dependencies(dependencies, free_targets),
            Enum.concat(nd_statements, reordered))
  end

  defp remove_satisfied_dependencies(dependencies, free_targets) do
    dependencies
    |> Enum.map(fn
      {_, []} -> nil
      {k, vs} -> {k, vs |> delete_all(free_targets)}
    end)
    |> Enum.filter(&(&1))
  end

  defp delete_all(vs, []), do: vs
  defp delete_all(vs, [h|t]), do: delete_all(List.delete(vs, h), t)
end

IO.inspect Day7.run
# => 46065
