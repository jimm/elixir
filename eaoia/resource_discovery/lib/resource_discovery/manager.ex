defmodule ResourceDiscovery.Manager do
  use GenServer.Behaviour

  @server __MODULE__
  @debug true

  defrecord State,
    target_resource_types: HashSet.new, # desired type keywords
    local_resource_dict: HashDict.new, # key = type, val = list of tuples
    found_resource_dict: HashDict.new  # ditto

  def start_link do
    :gen_server.start_link({:local, @server}, __MODULE__, [], [])
  end

  def init([]) do
    {:ok, State[]}
  end

  # ================ API ================

  def add_target_resource_type(type) do
    :gen_server.cast(@server, {:add_target_resource_type, type})
  end

  def add_local_resource(type, instance) do
    :gen_server.cast(@server, {:add_local_resource, {type, instance}})
  end

  def fetch_resources(type) do
    :gen_server.call(@server, {:fetch_resources, type})
  end

  def trade_resources() do
    :gen_server.cast(@server, :trade_resources)
  end

  # ================ GenServer ================

  def handle_call({:fetch_resources, type}, _from, state) do
    debug_print(":fetch_resources", state)
    {:reply, state.found_resource_dict[type], state}
  end

  def handle_cast({:add_target_resource_type, type}, state) do
    debug_print(":add_target_resource_type", state)
    new_trt = Set.put(state.target_resource_types, type)
    {:noreply, state.target_resource_types(new_trt)}
  end

  def handle_cast({:add_local_resource, {type, instance}}, state) do
    debug_print(":add_local_resource", state)
    new_resources = add_resource(state.local_resource_dict, type, instance)
    {:noreply, state.local_resource_dict(new_resources)}
  end

  def handle_cast(:trade_resources, state) do
    debug_print(":trade_resources", state)
    [Node.self | Node.list]
    |> Enum.map(fn(node) ->
                    :gen_server.cast({@server, node},
                                     {:trade_resources, {node(), state.local_resource_dict}})
                end)
    {:noreply, state}
  end

  def handle_cast({:trade_resources, {from, remotes}}, state) do
    debug_print("trade_resources", state)
    filtered_remotes = resources_for_types(remotes, state.target_resource_types)
    new_found = add_resources(state.found_resource_dict, filtered_remotes)
    case from do
      :noreply ->
        :ok
      _ ->
        :gen_server.cast({@server, from}, {:trade_resources, {:noreply, state.local_resource_dict}})
    end
    {:noreply, state.found_resource_dict(new_found)}
  end

  # ================ Support ================

  def add_resource(resource_dict, type, resource) do
    debug_print("add_resource resource_dict", resource_dict)
    debug_print("add_resource type", type)
    debug_print("add_resource resource", resource)
    case resource_dict[type] do
      nil ->
        Dict.put(resource_dict, type, HashSet.new([resource]))
      resources ->
        Dict.put(resource_dict, type, Set.put(resources, resource))
    end
  end

  def add_resources(resource_dict, [{type, resource} | tail]) do
    debug_print("add_resource resource_dict", resource_dict)
    debug_print("add_resource type", type)
    debug_print("add_resource resource", resource)
    debug_print("add_resource tail", tail)
    add_resources(add_resource(resource_dict, type, resource), tail)
  end

  def add_resources(resource_dict, []), do: resource_dict

  def resources_for_types(resource_dict, types) do
    debug_print("resources_for_types resource_dict", resource_dict)
    debug_print("resources_for_types types", types)
    f = fn(type, acc) ->
            case resource_dict[type] do
              nil ->
                acc
              set ->
                Enum.map(set, &({type, &1})) ++ acc
            end
        end
    HashSet.reduce(types, [], f)
  end

  if @debug do
    defp debug_print(msg, state) do
      IO.puts "#{msg} #{inspect(state)}"
    end
  else
    defp debug_print(_msg, _state) do
    end
  end
end
