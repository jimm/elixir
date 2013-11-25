defmodule SimpleCache.Event do

  @server __MODULE__

  def start_link do
    :gen_event.start_link({:local, @server})
  end

  def add_handler(handler, args) do
    :gen_event.add_handler(@server, handler, args)
  end

  def delete_handler(handler, args) do
    :gen_event.delete_handler(@server, handler, args)
  end

  def startup do
    :gen_event.notify(@server, :startup)
  end

  def lookup(key) do
    :gen_event.notify(@server, {:lookup, key})
  end

  def create(key, value) do
    :gen_event.notify(@server, {:create, {key, value}})
  end

  def replace(key, value) do
    :gen_event.notify(@server, {:replace, {key, value}})
  end

  def delete(key) do
    :gen_event.notify(@server, {:delete, key})
  end

end
