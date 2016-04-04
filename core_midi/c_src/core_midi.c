#include <CoreMIDI/MIDIServices.h>
/* #include <CoreFoundation/CFRunLoop.h> */
#include <stdio.h>
#include "types.h"
#include "core_midi.h"
#include "erl_comm.h"

int read_cmd(byte *buf);
int write_cmd(byte *buf, int len);

int main() {
  byte fn, buf[100];
  MIDIObjectRef obj;
  MIDIEndpointRef endpoint;
  CFStringRef cfstr;

  while (read_cmd(buf) > 0) {
    switch (buf[0]) {

    /* ================ Clients ================ */

    /* Creates a MIDIClient object. */
    case FUNC_MIDIClientCreate:
      break;

    /* Disposes a MIDIClient object. */
    case FUNC_MIDIClientDispose:
      break;

    /* ================ Ports ================ */

    /* Creates an input port through which the client may receive incoming MIDI messages from any MIDI source. */
    case FUNC_MIDIInputPortCreate:
      break;

    /* Creates an output port through which the client may send outgoing MIDI messages to any MIDI destination. */
    case FUNC_MIDIOutputPortCreate:
      break;

    /* Disposes a MIDIPort object. */
    case FUNC_MIDIPortDispose:
      break;

    /* Establishes a connection from a source to a client's input port. */
    case FUNC_MIDIPortConnectSource:
      break;

    /* Closes a previously-established source-to-input port connection. */
    case FUNC_MIDIPortDisconnectSource:
      break;

    /* ================ Devices ================ */

    /* Returns the number of devices in the system. */
    case FUNC_MIDIGetNumberOfDevices:
      buf[0] = MIDIGetNumberOfDevices();
      write_cmd(buf, 1);
      break;

    /* Returns one of the devices in the system. */
    case FUNC_MIDIGetDevice:
      break;

    /* Returns the number of entities in a given device. */
    case FUNC_MIDIDeviceGetNumberOfEntities:
      break;

    /* Returns one of a given device's entities. */
    case FUNC_MIDIDeviceGetEntity:
      break;

    /* ================ Entities ================ */

    /* Returns the number of sources in a given entity. */
    case FUNC_MIDIEntityGetNumberOfSources:
      break;

    /* Returns one of a given entity's sources. */
    case FUNC_MIDIEntityGetSource:
      break;

    /* Returns the number of destinations in a given entity. */
    case FUNC_MIDIEntityGetNumberOfDestinations:
      break;

    /* Returns one of a given entity's destinations. */
    case FUNC_MIDIEntityGetDestination:
      break;

    /* Returns an entity's device. */
    case FUNC_MIDIEntityGetDevice:
      break;

    /* ================ Endpoints ================ */

    /* Returns the number of sources in the system. */
    case FUNC_MIDIGetNumberOfSources:
      buf[0] = MIDIGetNumberOfSources();
      write_cmd(buf, 1);
      break;

    /* Returns one of the sources in the system. */
    case FUNC_MIDIGetSource:
      break;

    /* Returns the number of destinations in the system. */
    case FUNC_MIDIGetNumberOfDestinations:
      buf[0] = MIDIGetNumberOfDestinations();
      write_cmd(buf, 1);
      break;

    /* Returns one of the destinations in the system. */
    case FUNC_MIDIGetDestination:
      break;

    /* Returns an endpoint's entity. */
    case FUNC_MIDIEndpointGetEntity:
      break;

    /* Creates a virtual destination in a client. */
    case FUNC_MIDIDestinationCreate:
      break;

    /* Creates a virtual source in a client. */
    case FUNC_MIDISourceCreate:
      break;

    /* Disposes a virtual source or destination your client created. */
    case FUNC_MIDIEndpointDispose:
      break;

    /* ================ External Devices ================ */

    /* Returns the number of external MIDI devices in the system. */
    case FUNC_MIDIGetNumberOfExternalDevices:
      buf[0] = MIDIGetNumberOfExternalDevices();
      write_cmd(buf, 1);
      break;

    /* Returns one of the external devices in the system. */
    case FUNC_MIDIGetExternalDevice:
      break;

    /* ================ Objects and Properties ================ */

    /* Gets an object's integer-type property. */
    case FUNC_MIDIObjectGetIntegerProperty:
      obj = *(&buf[1]);
      cfstr = *(&buf[5]);
      buf[0] = MIDIObjectGetIntegerProperty(obj, cfstr, (SInt32 *)&buf[1]);
      write_cmd(buf, 1 + sizeof(SInt32));
      break;

    /* Sets an object's integer-type property. */
    case FUNC_MIDIObjectSetIntegerProperty:
      break;

    /* Gets an object's string-type property. */
    case FUNC_MIDIObjectGetStringProperty:
      break;

    /* Sets an object's string-type property. */
    case FUNC_MIDIObjectSetStringProperty:
      break;

    /* Gets an object's data-type property. */
    case FUNC_MIDIObjectGetDataProperty:
      break;

    /* Sets an object's data-type property. */
    case FUNC_MIDIObjectSetDataProperty:
      break;

    /* Gets an object's dictionary-type property. */
    case FUNC_MIDIObjectGetDictionaryProperty:
      break;

    /* Sets an object's dictionary-type property. */
    case FUNC_MIDIObjectSetDictionaryProperty:
      break;

    /* Gets all of an object's properties. */
    case FUNC_MIDIObjectGetProperties:
      break;

    /* Removes an object's property. */
    case FUNC_MIDIObjectRemoveProperty:
      break;

    /* Locates a device, external device, entity, or endpoint by its uniqueID.  */
    case FUNC_MIDIObjectFindByUniqueID:
      break;

    /* ================ MIDI I/O ================ */

    /* Sends MIDI to a destination. */
    case FUNC_MIDISend:
      break;

    /* Sends a single system-exclusive event, asynchronously. */
    case FUNC_MIDISendSysex:
      break;

    /* Distributes incoming MIDI from a source to the client input ports which are connected to that source. */
    case FUNC_MIDIReceived:
      break;

    /* Unschedules previously-sent packets. */
    case FUNC_MIDIFlushOutput:
      break;

    /* Stops and restarts MIDI I/O. */
    case FUNC_MIDIRestart:
      buf[0] = MIDIRestart();
      write_cmd(buf, 1);
      break;

    /* ================ Packet Lists ================ */

    /* Advances a MIDIPacket pointer to the MIDIPacket which immediately follows it in memory if it is part of a MIDIPacketList. */
    case FUNC_MIDIPacketNext:
      break;

    /* Prepares a MIDIPacketList to be built up dynamically. */
    case FUNC_MIDIPacketListInit:
      break;

    /* Adds a MIDI event to a MIDIPacketList. */
    case FUNC_MIDIPacketListAdd:
      break;
    }
  }
}
