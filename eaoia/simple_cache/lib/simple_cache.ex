defmodule SimpleCache do

  use Application.Behaviour
  alias SimpleCache.Store
  alias SimpleCache.Supervisor
  alias SimpleCache.Element
  alias SimpleCache.Event

  def start(_type, _args) do
    Store.init
    case Supervisor.start_link do
      {:ok, pid} ->
        Event.startup
        {:ok, pid}
      other -> {:error, other}
    end
  end

  def insert(key, value) do
    case Store.lookup(key) do
      {:ok, pid} ->
        retval = Element.replace(pid, value)
        Event.replace(key, value)
      {:error, _} ->
        {:ok, pid} = Element.create(value)
        retval = Store.insert(key, pid)
        Event.create(key, value)
    end
    retval
  end

  def lookup(key) do
    retval = try do
               {:ok, pid} = Store.lookup(key)
               {:ok, value} = Element.fetch(pid)
             catch
               _, _ ->
                 {:error, :not_found}
             end
    Event.lookup(key)
    retval
  end

  def delete(key) do
    case Store.lookup(key) do
      {:ok, pid} ->
        retval = Element.delete(pid)
      {:error, _} ->
        retval = :ok
    end
    Event.delete(key)
    retval
  end
end
