defmodule YamlToMapTest do
  use ExUnit.Case

  test "empty" do
    assert convert('[]') == []
    assert convert('{}') == %{}
    assert convert('') == nil
  end

  test "get back a map with atomic keys" do
    assert convert('{a: b}') == %{a: "b"}
  end

  test "more than one key" do
    assert convert('{a: b, c: 42}') == %{a: "b", c: 42}
  end

  test "convert list values" do
    assert convert('{a: [1, 2, 3]}') == %{a: [1, 2, 3]}
    assert convert('{a: [1, [2, 3]]}') == %{a: [1, [2, 3]]}
  end

  test "convert lists of strings" do
    assert convert('{a: [abc, def]}') == %{a: ["abc", "def"]}
  end

  test "recursive structures mapped" do
    assert convert('a: {b: c}') == %{a: %{b: "c"}}
  end

  defp convert(s) do
    yaml_doclist = s
      |> :yamerl_constr.string(detailed_constr: true)
    docs = YamlToMap.to_maps(yaml_doclist)
    if docs == [], do: nil, else: hd(docs)
  end
end
