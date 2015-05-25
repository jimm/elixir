defmodule CoreMIDI do

  def start do
    spawn(fn ->
		  :global.register_name(__MODULE__, self())
      Process.flag(:trap_exit, true)
		  port = Port.open({:spawn, "./bin/core_midi"}, [{:packet, 2}])
		  loop(port)
	  end)
  end

  def stop, do: send(app(), :stop)

  def app, do: :global.whereis_name(__MODULE__)

  def num_destinations, do: call_port(:num_destinations)
  def num_sources, do: call_port(:num_sources)
  def num_devices, do: call_port(:num_devices)
  def num_external_devices, do: call_port(:num_external_devices)

  def ping do
    :pong = call_port(:ping)
  end

  defp call_port(msg) do
    pid = app()
    send(pid, {:call, self(), msg})
    receive do
	    {^pid, result} -> result
    end
  end

  defp loop(port) do
    receive do
	    {:call, caller, :ping} ->
        send(caller, {self(), :pong})
        loop(port)
	    {:call, caller, msg} ->
	      send(port, {self(), {:command, encode(msg)}})
	      receive do
		      {^port, {:data, data}} ->
		        send(caller, {self(), decode(data)})
	      end
	      loop(port)
	    :stop ->
	      send(port, {self(), :close})
	      receive do
		      {^port, :closed} ->
		        exit(:normal)
	      end
	    {'EXIT', ^port, reason} ->
	      exit({:port_terminated, reason})
    end
  end

  defp encode(:num_destinations), do: [CoreMIDI.Consts.kFUNC_MIDIGetNumberOfDestinations]
  defp encode(:num_sources), do: [CoreMIDI.Consts.kFUNC_MIDIGetNumberOfSources]
  defp encode(:num_devices), do: [CoreMIDI.Consts.kFUNC_MIDIGetNumberOfDevices]
  defp encode(:num_external_devices), do: [CoreMIDI.Consts.kFUNC_MIDIGetNumberOfExternalDevices]

  defp decode([int]), do: int
end
