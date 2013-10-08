defmodule Midifile.Writer do

  use Bitwise

  # Channel messages
  @status_nibble_off 0x8
  @status_nibble_on 0x9
  @status_nibble_poly_press 0xA
  @status_nibble_controller 0xB
  @status_nibble_program_change 0xC
  @status_nibble_channel_pressure 0xD
  @status_nibble_pitch_bend 0xE

  # System common messages
  @status_sysex 0xF0
  @status_song_pointer 0xF2
  @status_song_select 0xF3
  @status_tune_request 0xF6
  @status_eox 0xF7

  # System realtime messages
  # MIDI clock (24 per quarter note)
  @status_clock 0xF8
  # Sequence start
  @status_start 0xFA
  # Sequence continue
  @status_continue 0xFB
  # Sequence stop
  @status_stop 0xFC
  # Active sensing (sent every 300 ms when nothing else being sent)
  @status_active_sense 0xFE
  # System reset
  @status_system_reset 0xFF

  # Meta events
  @status_meta_event 0xFF
  @meta_seq_num 0x00
  @meta_text 0x01
  @meta_copyright 0x02
  @meta_seq_name 0x03
  @meta_instrument 0x04
  @meta_lyric 0x05
  @meta_marker 0x06
  @meta_cue 0x07
  @meta_midi_chan_prefix 0x20
  @meta_track_end 0x2f
  @meta_set_tempo 0x51
  @meta_smpte 0x54
  @meta_time_sig 0x58
  @meta_key_sig 0x59
  @meta_sequencer_specific 0x7F

  @moduledoc """
  MIDI file writer.
  """

  def write(Sequence[header: header, conductor_track: ct, tracks: tracks], path) do
    l = [header_io_list(header, length(tracks) + 1) |
  	     Enum.map([ct | tracks], &(track_io_list(&1)))]
    :ok = :file.write_file(path, l)
  end

  def header_io_list({:header, _, division}, num_tracks) do
    ["MThd",
     0, 0, 0, 6,                  # header chunk size
     0, 1,                        # format,
     (num_tracks >>> 8) &&& 255, # num tracks
      num_tracks        &&& 255,
     (division >>> 8) &&& 255, # division
      division        &&& 255]
  end

  def track_io_list(Track[events: events]) do
    Process.put(:status, 0)
    Process.put(:chan, 0)
    event_list =  Enum.map(events, &(event_io_list(&1)))
    size = chunk_size(event_list)
    ["MTrk",
     (size >>> 24) &&& 255,
     (size >>> 16) &&& 255,
     (size >>>  8) &&& 255,
      size         &&& 255,
      event_list]
  end

  # Return byte size of L, which is an IO list that contains lists, bytes, and
  # binaries.
  def chunk_size(l) do
    acc = 0
    List.foldl(List.flatten(l), acc, fn(e, acc) -> acc + io_list_element_size(e) end)
  end

  def io_list_element_size(e) when is_binary(e), do: size(e)

  def io_list_element_size(_e), do: 1

  def event_io_list({:off, delta_time, [chan, note, vel]}) do
    running_status = Process.get(:status)
    running_chan = Process.get(:chan)
    if running_chan == chan and (running_status == @status_nibble_off or
  	                             (running_status == @status_nibble_on and vel == 64)) do
  	    status = []
  	    outvel = 0
    else
  	    status = (@status_nibble_off <<< 4) + chan
  	    outvel = vel
  	    Process.put(:status, @status_nibble_off)
  	    Process.put(:chan, chan)
    end
    [var_len(delta_time), status, note, outvel]
  end

  def event_io_list({:on, delta_time, [chan, note, vel]}),                 do: [var_len(delta_time), running_status(@status_nibble_on, chan), note, vel]
  def event_io_list({:poly_press, delta_time, [chan, note, amount]}),      do: [var_len(delta_time), running_status(@status_nibble_poly_press, chan), note, amount]
  def event_io_list({:controller, delta_time, [chan, controller, value]}), do: [var_len(delta_time), running_status(@status_nibble_controller, chan), controller, value]
  def event_io_list({:program, delta_time, [chan, program]}),              do: [var_len(delta_time), running_status(@status_nibble_program_change, chan), program]
  def event_io_list({:chan_press, delta_time, [chan, amount]}),            do: [var_len(delta_time), running_status(@status_nibble_channel_pressure, chan), amount]

  def event_io_list({:pitch_bend, delta_time, [chan, <<0::size(2), msb::size(7), lsb::size(7)>>]}) do
    [var_len(delta_time), running_status(@status_nibble_pitch_bend, chan), <<0::size(1), lsb::size(7), 0::size(1), msb::size(7)>>]
  end

  def event_io_list({:track_end, delta_time}) do
    Process.put(:status, @status_meta_event)
    [var_len(delta_time), @status_meta_event, @meta_track_end, 0]
  end

  def event_io_list({:seq_num, delta_time, [data]}),          do: meta_io_list(delta_time, @meta_seq_num, data)
  def event_io_list({:text, delta_time, data}),               do: meta_io_list(delta_time, @meta_text, data)
  def event_io_list({:copyright, delta_time, data}),          do: meta_io_list(delta_time, @meta_copyright, data)
  def event_io_list({:seq_name, delta_time, data}) do
    Process.put(:status, @status_meta_event)
    meta_io_list(delta_time, @meta_track_end, data)
  end
  def event_io_list({:instrument, delta_time, data}),         do: meta_io_list(delta_time, @meta_instrument, data)
  def event_io_list({:lyric, delta_time, data}),              do: meta_io_list(delta_time, @meta_lyric, data)
  def event_io_list({:marker, delta_time, data}),             do: meta_io_list(delta_time, @meta_marker, data)
  def event_io_list({:cue, delta_time, data}),                do: meta_io_list(delta_time, @meta_cue, data)
  def event_io_list({:midi_chan_prefix, delta_time, [data]}), do: meta_io_list(delta_time, @meta_midi_chan_prefix, data)

  def event_io_list({:tempo, delta_time, [data]}) do
    Process.put(:status, @status_meta_event)
    [var_len(delta_time), @status_meta_event, @meta_set_tempo, var_len(3),
     (data >>> 16) &&& 255,
     (data >>>  8) &&& 255,
      data         &&& 255]
  end

  def event_io_list({:smpte, delta_time, [data]}),              do: meta_io_list(delta_time, @meta_smpte, data)
  def event_io_list({:time_signature, delta_time, [data]}),     do: meta_io_list(delta_time, @meta_time_sig, data)
  def event_io_list({:key_signature, delta_time, [data]}),      do: meta_io_list(delta_time, @meta_key_sig, data)
  def event_io_list({:sequencer_specific, delta_time, [data]}), do: meta_io_list(delta_time, @meta_sequencer_specific, data)
  def event_io_list({:unknown_meta, delta_time, [type, data]}), do: meta_io_list(delta_time, type, data)

  def meta_io_list(delta_time, type, data) when is_binary(data) do
    Process.put(:status, @status_meta_event)
    [var_len(delta_time), @status_meta_event, type, var_len(size(data)), data]
  end

  def meta_io_list(delta_time, type, data) do
    Process.put(:status, @status_meta_event)
    [var_len(delta_time), @status_meta_event, type, var_len(length(data)), data]
  end

  def running_status(high_nibble, chan) do
    running_status = Process.get(:status)
    running_chan = Process.get(:chan)
    if running_status == high_nibble and running_chan == chan do
  	    []
    else
  	    Process.put(:status, high_nibble)
  	    Process.put(:chan, chan)
  	    (high_nibble <<< 4) + chan
    end
  end

  def var_len(i) when i < (1 <<< 7),  do: <<0::size(1), i::size(7)>>
  def var_len(i) when i < (1 <<< 14), do: <<1::size(1), (i >>> 7)::size(7), 0::size(1), i::size(7)>>
  def var_len(i) when i < (1 <<< 21), do: <<1::size(1), (i >>> 14)::size(7), 1::size(1), (i >>> 7)::size(7), 0::size(1), i::size(7)>>
  def var_len(i) when i < (1 <<< 28), do: <<1::size(1), (i >>> 21)::size(7), 1::size(1), (i >>> 14)::size(7), 1::size(1), (i >>> 7)::size(7), 0::size(1), i::size(7)>>
  def var_len(i),                     do: exit("Value #{i} is too big for a variable length number")

end
