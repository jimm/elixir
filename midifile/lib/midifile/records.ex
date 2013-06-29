defrecord Event,
  symbol: :off,
  delta_time: 0,
  bytes: []

defrecord Track,
  name: "Unnamed",
  events: []

defrecord Sequence,
  header: nil,
  conductor_track: nil,
  tracks: []
