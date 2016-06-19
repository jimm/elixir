#!/usr/bin/env elixir

defmodule Monitor1 do
  import :timer, only: [sleep: 1]

  def sad_function do
    sleep(500)
    exit(:boom)
  end

  def run do
    {child_pid, mon_ref} = spawn_monitor(__MODULE__, :sad_function, [])
    IO.puts "child: #{inspect child_pid}"
    IO.puts "monitor: #{inspect mon_ref}"
    IO.puts "self: #{inspect self}"
    receive do
      msg ->
        IO.puts "Message received: #{inspect msg}"
    after 1000 ->
        IO.puts "Nothing happened as far as I'm concerned"
    end
  end
end

Monitor1.run
