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

  # ================ Clients ================

  def client_create, do: call_port(:client_create)
  def client_dispose, do: call_port(:client_dispose)

  # ================ Ports ================

  def input_port_create, do: call_port(:input_port_create)
  def output_port_create, do: call_port(:output_port_create)
  def port_dispose, do: call_port(:port_dispose)
  def port_connect_source, do: call_port(:port_connect_source)
  def port_disconnect_source, do: call_port(:port_disconnect_source)

  # ================ Devices ================

  def num_devices, do: call_port(:num_devices)
  def device, do: call_port(:device)
  def device_num_entities, do: call_port(:device_num_entities)
  def device_entity, do: call_port(:device_entity)

  # ================ Entities ================

  def entity_num_sources, do: call_port(:entity_num_sources)
  def entity_source, do: call_port(:entity_source)
  def entity_num_destinations, do: call_port(:entity_num_destinations)
  def entity_destination, do: call_port(:entity_destination)
  def entity_device, do: call_port(:entity_device)

  # ================ ClientEndpoints ================

  def num_sources, do: call_port(:num_sources)
  def source, do: call_port(:source)
  def num_destinations, do: call_port(:num_destinations)
  def destination, do: call_port(:destination)
  def endpoint_entity, do: call_port(:endpoint_entity)
  def destination_create, do: call_port(:destination_create)
  def source_create, do: call_port(:source_create)
  def endpoint_dispose, do: call_port(:endpoint_dispose)

  # ================ ClientExternal Devices ================

  def num_external_devices, do: call_port(:num_external_devices)
  def external_device, do: call_port(:external_device)

  # ================ Objects and Properties ================

  def int_prop, do: call_port(:int_prop)
  def set_int_prop, do: call_port(:set_int_prop)
  def string_prop, do: call_port(:string_prop)
  def set_string_prop, do: call_port(:set_string_prop)
  def data_prop, do: call_port(:data_prop)
  def set_data_prop, do: call_port(:set_data_prop)
  def dict_prop, do: call_port(:dict_prop)
  def set_dict_prop, do: call_port(:set_dict_prop)
  def props, do: call_port(:props)
  def remove_prop, do: call_port(:remove_prop)
  def obj_find_by_unique_id, do: call_port(:obj_find_by_unique_id)

  # ================ MIDI I/O ================

  def send_midi, do: call_port(:send)
  def send_sysex, do: call_port(:send_sysex)
  def received, do: call_port(:received)
  def flush_output, do: call_port(:flush_output)
  def restart, do: call_port(:restart)

  # ================ Packet Lists ================

  def packet_next, do: call_port(:packet_next)
  def packet_list_init, do: call_port(:packet_list_init)
  def packet_list_add, do: call_port(:packet_list_add)

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

  # ================ Clients ================

  defp encode(:client_create), do: [CoreMIDI.Consts.kFUNC_MIDIClientCreate]
  defp encode(:client_dispose), do: [CoreMIDI.Consts.kFUNC_MIDIClientDispose]

  # ================ Ports ================

  defp encode(:input_port_create), do: [CoreMIDI.Consts.kFUNC_MIDIInputPortCreate]
  defp encode(:output_port_create), do: [CoreMIDI.Consts.kFUNC_MIDIOutputPortCreate]
  defp encode(:port_dispose), do: [CoreMIDI.Consts.kFUNC_MIDIPortDispose]
  defp encode(:port_connect_source), do: [CoreMIDI.Consts.kFUNC_MIDIPortConnectSource]
  defp encode(:port_disconnect_source), do: [CoreMIDI.Consts.kFUNC_MIDIPortDisconnectSource]

  # ================ Devices ================

  defp encode(:num_devices), do: [CoreMIDI.Consts.kFUNC_MIDIGetNumberOfDevices]
  defp encode(:device), do: [CoreMIDI.Consts.kFUNC_MIDIGetDevice]
  defp encode(:device_num_entities), do: [CoreMIDI.Consts.kFUNC_MIDIDeviceGetNumberOfEntities]
  defp encode(:device_entity), do: [CoreMIDI.Consts.kFUNC_MIDIDeviceGetEntity]

  # ================ Entities ================

  defp encode(:entity_num_sources), do: [CoreMIDI.Consts.kFUNC_MIDIEntityGetNumberOfSources]
  defp encode(:entity_source), do: [CoreMIDI.Consts.kFUNC_MIDIEntityGetSource]
  defp encode(:entity_num_destinations), do: [CoreMIDI.Consts.kFUNC_MIDIEntityGetNumberOfDestinations]
  defp encode(:entity_destination), do: [CoreMIDI.Consts.kFUNC_MIDIEntityGetDestination]
  defp encode(:entity_device), do: [CoreMIDI.Consts.kFUNC_MIDIEntityGetDevice]

  # ================ Endpoints ================

  defp encode(:num_sources), do: [CoreMIDI.Consts.kFUNC_MIDIGetNumberOfSources]
  defp encode(:source), do: [CoreMIDI.Consts.kFUNC_MIDIGetSource]
  defp encode(:num_destinations), do: [CoreMIDI.Consts.kFUNC_MIDIGetNumberOfDestinations]
  defp encode(:destination), do: [CoreMIDI.Consts.kFUNC_MIDIGetDestination]
  defp encode(:endpoint_entity), do: [CoreMIDI.Consts.kFUNC_MIDIEndpointGetEntity]
  defp encode(:destination_create), do: [CoreMIDI.Consts.kFUNC_MIDIDestinationCreate]
  defp encode(:source_create), do: [CoreMIDI.Consts.kFUNC_MIDISourceCreate]
  defp encode(:endpoint_dispose), do: [CoreMIDI.Consts.kFUNC_MIDIEndpointDispose]

  # ================ External Devices ================

  defp encode(:num_external_devices), do: [CoreMIDI.Consts.kFUNC_MIDIGetNumberOfExternalDevices]
  defp encode(:external_device), do: [CoreMIDI.Consts.kFUNC_MIDIGetExternalDevice]

  # ================ Objects and Properties ================

  defp encode(:int_prop), do: [CoreMIDI.Consts.kFUNC_MIDIObjectGetIntegerProperty]
  defp encode(:set_int_prop), do: [CoreMIDI.Consts.kFUNC_MIDIObjectSetIntegerProperty]
  defp encode(:string_prop), do: [CoreMIDI.Consts.kFUNC_MIDIObjectGetStringProperty]
  defp encode(:set_string_prop), do: [CoreMIDI.Consts.kFUNC_MIDIObjectSetStringProperty]
  defp encode(:data_prop), do: [CoreMIDI.Consts.kFUNC_MIDIObjectGetDataProperty]
  defp encode(:set_data_prop), do: [CoreMIDI.Consts.kFUNC_MIDIObjectSetDataProperty]
  defp encode(:dict_prop), do: [CoreMIDI.Consts.kFUNC_MIDIObjectGetDictionaryProperty]
  defp encode(:set_dict_prop), do: [CoreMIDI.Consts.kFUNC_MIDIObjectSetDictionaryProperty]
  defp encode(:props), do: [CoreMIDI.Consts.kFUNC_MIDIObjectGetProperties]
  defp encode(:remove_prop), do: [CoreMIDI.Consts.kFUNC_MIDIObjectRemoveProperty]
  defp encode(:obj_find_by_unique_id), do: [CoreMIDI.Consts.kFUNC_MIDIObjectFindByUniqueID]

  # ================ MIDI I/O ================

  defp encode(:send_midi), do: [CoreMIDI.Consts.kFUNC_MIDISend]
  defp encode(:send_sysex), do: [CoreMIDI.Consts.kFUNC_MIDISendSysex]
  defp encode(:received), do: [CoreMIDI.Consts.kFUNC_MIDIReceived]
  defp encode(:flush_output), do: [CoreMIDI.Consts.kFUNC_MIDIFlushOutput]
  defp encode(:restart), do: [CoreMIDI.Consts.kFUNC_MIDIRestart]

  # ================ Packet Lists ================

  defp encode(:packet_next), do: [CoreMIDI.Consts.kFUNC_MIDIPacketNext]
  defp encode(:packet_list_init), do: [CoreMIDI.Consts.kFUNC_MIDIPacketListInit]
  defp encode(:packet_list_add), do: [CoreMIDI.Consts.kFUNC_MIDIPacketListAdd]

  # ================ Helpers ================

  defp decode([int]), do: int
end
