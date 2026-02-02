defmodule SimpleRegistryTest do
  use ExUnit.Case
  doctest SimpleRegistry

  test "greets the world" do
    assert SimpleRegistry.hello() == :world
  end
end
