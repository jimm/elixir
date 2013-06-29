defmodule Midifile do

  def read(path) do
    Midifile.Reader.read(path)
  end

  def write(_sequence, _path) do
  end

end
