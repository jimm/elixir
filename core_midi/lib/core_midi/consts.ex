defmodule CoreMIDI.Consts do

  # Creates a MIDIClient object.
  def kFUNC_MIDIClientCreate, do: 1

  # Disposes a MIDIClient object.
  def kFUNC_MIDIClientDispose, do: 2

  # Creates an input port through which the client may receive incoming MIDI
  # messages from any MIDI source.
  def kFUNC_MIDIInputPortCreate, do: 3

  # Creates an output port through which the client may send outgoing MIDI
  # messages to any MIDI destination.
  def kFUNC_MIDIOutputPortCreate, do: 4

  # Disposes a MIDIPort object.
  def kFUNC_MIDIPortDispose, do: 5

  # Establishes a connection from a source to a client's input port.
  def kFUNC_MIDIPortConnectSource, do: 6

  # Closes a previously-established source-to-input port connection.
  def kFUNC_MIDIPortDisconnectSource, do: 7

  # Returns the number of devices in the system.
  def kFUNC_MIDIGetNumberOfDevices, do: 8

  # Returns one of the devices in the system.
  def kFUNC_MIDIGetDevice, do: 9

  # Returns the number of entities in a given device.
  def kFUNC_MIDIDeviceGetNumberOfEntities, do: 10

  # Returns one of a given device's entities.
  def kFUNC_MIDIDeviceGetEntity, do: 11

  # Returns the number of sources in a given entity.
  def kFUNC_MIDIEntityGetNumberOfSources, do: 12

  # Returns one of a given entity's sources.
  def kFUNC_MIDIEntityGetSource, do: 13

  # Returns the number of destinations in a given entity.
  def kFUNC_MIDIEntityGetNumberOfDestinations, do: 14

  # Returns one of a given entity's destinations.
  def kFUNC_MIDIEntityGetDestination, do: 15

  # Returns an entity's device.
  def kFUNC_MIDIEntityGetDevice, do: 16

  # Returns the number of sources in the system.
  def kFUNC_MIDIGetNumberOfSources, do: 17

  # Returns one of the sources in the system.
  def kFUNC_MIDIGetSource, do: 18

  # Returns the number of destinations in the system.
  def kFUNC_MIDIGetNumberOfDestinations, do: 19

  # Returns one of the destinations in the system.
  def kFUNC_MIDIGetDestination, do: 20

  # Returns an endpoint's entity.
  def kFUNC_MIDIEndpointGetEntity, do: 21

  # Creates a virtual destination in a client.
  def kFUNC_MIDIDestinationCreate, do: 22

  # Creates a virtual source in a client.
  def kFUNC_MIDISourceCreate, do: 23

  # Disposes a virtual source or destination your client created.
  def kFUNC_MIDIEndpointDispose, do: 24

  # Returns the number of external MIDI devices in the system.
  def kFUNC_MIDIGetNumberOfExternalDevices, do: 25

  # Returns one of the external devices in the system.
  def kFUNC_MIDIGetExternalDevice, do: 26

  # Gets an object's integer-type property.
  def kFUNC_MIDIObjectGetIntegerProperty, do: 27

  # Sets an object's integer-type property.
  def kFUNC_MIDIObjectSetIntegerProperty, do: 28

  # Gets an object's string-type property.
  def kFUNC_MIDIObjectGetStringProperty, do: 29

  # Sets an object's string-type property.
  def kFUNC_MIDIObjectSetStringProperty, do: 30

  # Gets an object's data-type property.
  def kFUNC_MIDIObjectGetDataProperty, do: 31

  # Sets an object's data-type property.
  def kFUNC_MIDIObjectSetDataProperty, do: 32

  # Gets an object's dictionary-type property.
  def kFUNC_MIDIObjectGetDictionaryProperty, do: 33

  # Sets an object's dictionary-type property.
  def kFUNC_MIDIObjectSetDictionaryProperty, do: 34

  # Gets all of an object's properties.
  def kFUNC_MIDIObjectGetProperties, do: 35

  # Removes an object's property.
  def kFUNC_MIDIObjectRemoveProperty, do: 36

  # Locates a device, external device, entity, or endpoint by its uniqueID.
  def kFUNC_MIDIObjectFindByUniqueID, do: 37

  # Sends MIDI to a destination.
  def kFUNC_MIDISend, do: 38

  # Sends a single system-exclusive event, asynchronously.
  def kFUNC_MIDISendSysex, do: 39

  # Distributes incoming MIDI from a source to the client input ports which
  # are connected to that source.
  def kFUNC_MIDIReceived, do: 40

  # Unschedules previously-sent packets.
  def kFUNC_MIDIFlushOutput, do: 41

  # Stops and restarts MIDI I/O.
  def kFUNC_MIDIRestart, do: 42

  # Advances a MIDIPacket pointer to the MIDIPacket which immediately
  # follows it in memory if it is part of a MIDIPacketList.
  def kFUNC_MIDIPacketNext, do: 43

  # Prepares a MIDIPacketList to be built up dynamically.
  def kFUNC_MIDIPacketListInit, do: 44

  # Adds a MIDI event to a MIDIPacketList.
  def kFUNC_MIDIPacketListAdd, do: 45

  def kERR_kMIDIInvalidClient, do: -10830
  def kERR_kMIDIInvalidPort, do: -10831
  def kERR_kMIDIWrongEndpointType, do: -10832
  def kERR_kMIDINoConnection, do: -10833
  def kERR_kMIDIUnknownEndpoint, do: -10834
  def kERR_kMIDIUnknownProperty, do: -10835
  def kERR_kMIDIWrongPropertyType, do: -10836
  def kERR_kMIDINoCurrentSetup, do: -10837
  def kERR_kMIDIMessageSendErr, do: -10838
  def kERR_kMIDIServerStartErr, do: -10839
  def kERR_kMIDISetupFormatErr, do: -10840
  def kERR_kMIDIWrongThread, do: -10841
  def kERR_kMIDIObjectNotFound, do: -10842
  def kERR_kMIDIIDNotUnique, do: -1084

  def kREF_SIZE, do: 8

end
