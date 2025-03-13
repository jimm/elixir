#! /usr/bin/env elixir

defmodule Twins do
  def pname do
    receive do
      {from, name} -> send(from, {self(), name})
    end
  end

  def run do
    # ~w(fred betty barney dino)
    names = 1..10
    pids = Enum.map(names, fn _ -> spawn(__MODULE__, :pname, []) end)

    Enum.zip(names, pids)
    |> Enum.map(fn {name, pid} -> send(pid, {self(), name}) end)

    # Receive responses. names used to run N times; name not used here.
    names
    |> Enum.each(fn _ ->
      receive do
        {_, name} -> IO.puts(name)
      end
    end)
  end
end

Twins.run()
