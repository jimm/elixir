#!/usr/bin/env elixir

defmodule MultiProc1 do
  def send_then_exit(parent) do
    IO.puts "parent = #{inspect parent}"
    send(parent, {self, :hello_goodbye})
    # IO.puts "child raising error"
    # raise "help!"
    IO.puts "child exiting"
    exit(:boom)
  end

  def run do
    IO.puts "self = #{inspect self}"
    # Process.flag(:trap_exit, true)
    spawn_monitor(__MODULE__, :send_then_exit, [self])
    IO.puts "sleeping"
    :timer.sleep(500)
    IO.puts "outputting messages"
    output_all_messages
  end

  def output_all_messages do
    receive do
      msg ->
        IO.puts "message received: #{inspect msg}"
        output_all_messages
    end
  end
end

MultiProc1.run
