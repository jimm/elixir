defmodule SimpleRegistryTest do
  use ExUnit.Case
  doctest SimpleRegistry

  test "registers this process with self()" do
    SimpleRegistry.start_link()
    SimpleRegistry.register(:me)
    assert SimpleRegistry.whereis(:me) == self()
  end

  test "removes a process from the registry when it exist" do
    SimpleRegistry.start_link()
    current = self()

    # Register another process then exit it, after sending us a callback we
    # can wait for.
    spawn(fn ->
      SimpleRegistry.register(:other)

      # make sure registered PID isn't the test's PID
      assert self() != current
      # ...and we registered ours
      assert SimpleRegistry.whereis(:other) == self()

      send(current, :ok)
    end)

    receive do
      :ok -> nil
    end

    assert SimpleRegistry.whereis(:other) == nil
  end
end
