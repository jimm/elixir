defmodule SimpleCache do

  use Application.Behaviour
  alias SimpleCache.Store
  alias SimpleCache.Supervisor
  alias SimpleCache.Element

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Store.init
    case Supervisor.start_link do
      {:ok, pid} -> {:ok, pid}
      other -> {:error, other}
    end
  end

  def insert(key, value) do
    case Store.lookup(key) do
      {:ok, pid} ->
        Element.replace(pid, value)
      {:error, _} ->
        {:ok, pid} = Element.create(value)
        Store.insert(key, pid)
    end
  end

  def lookup(key) do
    try do
      {:ok, pid} = Store.lookup(key)
      {:ok, value} = Element.fetch(pid)
    catch
      _, _ ->
        {:error, :not_found}
    end
  end

  def delete(key) do
    case Store.lookup(key) do
      {:ok, pid} -> Element.delete(pid)
      {:error, _} -> :ok
    end
  end
end
