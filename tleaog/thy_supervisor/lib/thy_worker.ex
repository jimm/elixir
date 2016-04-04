defmodule ThyWorker do
  def start_link do
    spawn_link(fn -> loop end)
  end

  def loop do
    receive do
      :stop -> :ok
      msg ->
        IO.inspect msg
        loop
    end
  end
end
