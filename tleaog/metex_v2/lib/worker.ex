defmodule Metex.Worker do
  
  @moduledoc """
  Retrieve temperatures in one or more cities.
  """

  @name __MODULE__
  @base_url "http://jsonplaceholder.typicode.com"

  use GenServer

  # ================ Client API ================


  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: @name])
  end

  def get_resource(resource) do
    GenServer.call(@name, {:resource, resource})
  end

  def get_stats do
    GenServer.call(@name, :get_stats)
  end

  def reset_stats do
    GenServer.cast(@name, :reset_stats)
  end

  # ================ GenServer ================

  def init(:ok) do
    {:ok, %{}}
  end

  # ================ Server ================

  def handle_call({:resource, resource}, _from, stats) do
    rsrc = data_of(resource)
    {:reply, rsrc, update_stats(stats, rsrc)}
  end
  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  def handle_cast(:reset_stats, _from, stats) do
    {:noreply, %{}}
  end

  # ================ Private ================

  def data_of(resource) do
    url_for(resource) |> HTTPoison.get |> parse_response
  end

  def url_for(resource) do
    @base_url <> resource
  end

  def parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> Poison.decode!
  end
  def parse_response(_), do: :error

  def update_stats(old_stats, resource) do
	  case Map.has_key?(old_stats, resource) do
      true -> Map.update!(old_stats, resource, &(&1 + 1))
      false -> Map.put_new(old_stats, resource, 1)
    end
  end
end
