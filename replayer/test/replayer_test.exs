defmodule ReplayerTest do
  use ExUnit.Case

  test "parsing" do
    line = ~s{- - [03/Aug/2013:02:34:56 -0800] "GET /the/uri HTTP/1.1" 200 3116 "more" "stuff"}
    request = Replayer.LogParser.parse(line)
    t = {{2013, 8, 3}, {2, 34, 56}}
    assert %Replayer.Request{time: t, verb: "GET", uri: "/the/uri"} == request
  end
end
