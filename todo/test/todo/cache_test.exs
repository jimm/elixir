defmodule Todo.CacheTest do
  use ExUnit.Case

  setup_all do
    on_exit(fn ->
      Todo.Database.delete("jane")
      Todo.Database.delete("john")
    end)

    {:ok, []}
  end

  test "server_process" do
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "to-do operations" do
    d = ~D[2018-12-19]
    jane = Todo.Cache.server_process("jane")
    Todo.Server.add_entry(jane, %{date: d, title: "Dentist"})
    entries = Todo.Server.entries(jane, d)

    assert [%{date: ^d, title: "Dentist"}] = entries
  end

  test "persistence" do
    d = ~D[2018-12-20]
    john = Todo.Cache.server_process("john")
    Todo.Server.add_entry(john, %{date: d, title: "Shopping"})
    assert 1 == length(Todo.Server.entries(john, d))

    # Note to self: we'll get an error later if the server doesn't use a
    # timeout (Todo.Server's @expiry_idle_timeout, even if it's :infinity).
    Process.exit(john, :kill)

    entries =
      "john"
      |> Todo.Cache.server_process()
      |> Todo.Server.entries(d)

    assert [%{date: ^d, title: "Shopping"}] = entries
  end
end
