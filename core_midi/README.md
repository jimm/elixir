# CoreMIDI

This is an example Elixir wrapper around Apple CoreMIDI functions. The code
in `c_src` is a modification of code posted by Joe Armstrong years ago.

- Compile the C code using the Makefile
- Start the CoreMIDI app with `CoreMIDI.start`
- Call functions (e.g, `CoreMIDI.num_destinations`)
- Stop the app with `CoreMIDI.stop`
