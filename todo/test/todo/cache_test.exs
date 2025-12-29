defmodule Todo.CacheTest do
  use ExUnit.Case
  doctest Todo.Cache

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "cache_test_bob")
    assert bob_pid != Todo.Cache.server_process(cache, "cache_test_alice")
    assert bob_pid == Todo.Cache.server_process(cache, "cache_test_bob")

    Todo.Database.delete("cache_test_alice")
    Todo.Database.delete("cache_test_bob")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()
    alice = Todo.Cache.server_process(cache, "cache_test_alice")
    Todo.Server.add_entry(alice, %{date: ~D[2023-12-19], title: "Dentist"})

    entries = Todo.Server.entries(alice, ~D[2023-12-19])
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries

    Todo.Database.delete("cache_test_alice")
  end
end
