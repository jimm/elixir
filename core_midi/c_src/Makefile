CORE_MIDI_LIB = CoreMIDI
MODS = core_midi
bindir = ../bin

core_midi: core_midi.c core_midi.h erl_comm.c erl_comm.h types.h $(bindir)
	gcc -framework $(CORE_MIDI_LIB) -o $(bindir)/core_midi core_midi.c erl_comm.c

$(bindir):
	mkdir -p $(bindir)

clean:
	rm -f $(bindir)/core_midi
