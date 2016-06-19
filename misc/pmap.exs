defmodule Parallel do
  def pmap(coll, fun) do
    me = self
    coll
      |> Enum.map(fn (e) ->
           spawn_link(fn -> send(me, {self, fun.(e)}) end)
         end)
      |> Enum.map(fn (pid) ->
           receive do {^pid, result} -> result end
         end)
  end

  def pmap2(coll, fun) do
    coll
    |> Enum.map(&(Task.async(fn -> fun.(&1) end)))
    |> Enum.map(&Task.await/1)
  end
end
