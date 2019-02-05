defmodule YamlToMap do
  @moduledoc """
  Converts the output of :yamerl_constr (using the :detailed_constr option)
  and turns it into a list of Elixir maps.
  """

  def to_maps(docs) when is_list(docs) do
    docs |> Enum.map(&_to_map(&1))
  end

  defp _to_map({:yamerl_doc, doc}), do: _to_map(doc)

  defp _to_map({:yamerl_seq, :yamerl_node_seq, _tag, _loc, seq, _n}) do
    seq |> Enum.map(&_to_map(&1))
  end

  defp _to_map({:yamerl_map, :yamerl_node_map, _tag, _loc, map_tuples}) do
    _tuples_to_map(map_tuples, %{})
  end

  defp _to_map({:yamerl_str, :yamerl_node_str, _tag, _loc, charlist}) do
    String.from_char_data!(charlist)
  end

  defp _to_map({:yamerl_int, :yamerl_node_int, _tag, _loc, n}) do
    n
  end

  defp _tuples_to_map([], map), do: map

  defp _tuples_to_map([{key, val} | rest], map) do
    {:yamerl_str, :yamerl_node_str, _tag, _log, name} = key
    _tuples_to_map(rest, Dict.put_new(map, String.to_atom(name), _to_map(val)))
  end
end
