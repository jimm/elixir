defmodule ResourceDiscoveryTest do
  use ExUnit.Case
  alias ResourceDiscovery.Manager

  test "adding a single resource" do
    d = HashDict.new
      |> Manager.add_resource(:jelly, "foo")
    assert d[:jelly] == HashSet.new(["foo"])
  end

  test "adding another resource adds to list" do
    d = HashDict.new
        |> Manager.add_resource(:jelly, "foo")
        |> Manager.add_resource(:jelly, "bar")
    assert d[:jelly] == HashSet.new(["foo", "bar"])
  end

  test "adding a list of resources" do
    d = HashDict.new
      |> Manager.add_resources([{:jelly, "foo"}, {:bread, "bar"}])
    assert d[:jelly] == HashSet.new(["foo"])
    assert d[:bread] == HashSet.new(["bar"])
  end

  test "resources for types" do
    d = HashDict.new(jelly: HashSet.new(["foo1", "foo2"]), bread: HashSet.new(["bar"]))
    assert HashSet.new(jelly: "foo1", jelly: "foo2") == Manager.resources_for_types(d, [:jelly])
  end
end
