defmodule Twins do
  def pname do
    receive do
      {from, name} -> send(from, {self, name})
    end
  end

  def run do
    names = 1..10 # ~w(fred betty barney dino)
    pids = Enum.map(names, fn _ -> spawn(__MODULE__, :pname, []) end)
    Enum.zip(names, pids)
      |> Enum.map(fn {name, pid} -> send(pid, {self, name}) end)

    # Receive responses. names used to run N times; name not used here.
    names |>
      Enum.each(fn _ ->  
        receive do
          {_, name} -> IO.puts name
        end
      end)
  end
end

Twins.run
