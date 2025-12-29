defmodule Todo.CacheTest do
  use ExUnit.Case
  doctest Todo.Cache

  setup do
    on_exit(:db_cleanup, fn ->
      Todo.Database.delete("cache_test_alice")
      Todo.Database.delete("cache_test_bob")
    end)
  end

  test "server_process" do
    {:ok, _} = Todo.Cache.start_link(nil)
    bob_pid = Todo.Cache.server_process("cache_test_bob")

    assert bob_pid != Todo.Cache.server_process("cache_test_alice")
    assert bob_pid == Todo.Cache.server_process("cache_test_bob")
  end

  test "to-do operations" do
    {:ok, _} = Todo.Cache.start_link(nil)
    alice = Todo.Cache.server_process("cache_test_alice")
    Todo.Server.add_entry(alice, %{date: ~D[2023-12-19], title: "Dentist"})
    entries = Todo.Server.entries(alice, ~D[2023-12-19])
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries
  end
end
