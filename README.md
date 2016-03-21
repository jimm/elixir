# Jim's Elixir Experiments

This repo contains my experiments with Elixir. See also my other repos:

- https://github.com/jimm/csvlixir
- https://github.com/jimm/elixir-midifile
- https://github.com/jimm/erlang-midilib
- https://github.com/jimm/elixir_resource_discovery

## CryptoPals

http://cryptopals.com/, though I'm also working on those in Clojure.

## Core MIDI

A MIDI file reader/writer. See https://github.com/jimm/elixir-midifile

This is an example Elixir wrapper around Apple CoreMIDI functions. The code
in `c_src` is a modification of code posted by Joe Armstrong years ago.

## Rails to Phoenix

A few scripts in this directory are attempts to automate conversion of Ruby
on Rails models to Phoenix models. The best one so far is
[schema_rb_to_phoenix_models.rb](schema_rb_to_phoenix_models.rb).

## Replayer

Replays an Apache log file.

## SimpleCache

A translation to Elixir of the simple cache application from _Erlang and OTP
in Action_.

## TCP RPC

A translation to Elixir of an exercise from _Erlang and OTP in Action_.

## YAML

Converts the output of `:yamerl_constr` into a list of Elixir maps.
See the [README](yaml/README.md).
