defmodule Day14 do
  # @input_file "test.txt"
  @input_file "data/day_14.txt"
  @parse_regex ~r{(\w+) can fly (\d+) km/s for (\d+) seconds, but then must rest for (\d+) seconds\.}

  defstruct [:name, :speed, :duration, :rest,
             :state, :time_in_state, :dist_travelled, :points]

  def max_dist do
    read_reindeer
    |> Enum.map(&(distance_at(&1, 2503)))
    |> Enum.max
  end

  def winning_points(race_duration \\ 2503) do
    read_reindeer
    |> race(race_duration-1)
    |> Enum.map(&(&1.points))
    |> IO.inspect
    |> Enum.max
  end

  defp read_reindeer do
    File.stream!(@input_file)
    |> Enum.reduce([], fn line, acc ->
      [name, speed, dur, rest] = parse(line)
      [%Day14{name: name,
              speed: String.to_integer(speed),
              duration: String.to_integer(dur),
              rest: String.to_integer(rest),
              state: :flying, time_in_state: 0, dist_travelled: 0, points: 0}
       | acc]
    end)
  end

  defp parse(line) do
    Regex.run(@parse_regex, line) |> tl
  end

  # ================ method one ================

  defp distance_at(reindeer, secs) do
    distance_at(reindeer, 0, :fly, secs)
  end

  defp distance_at(reindeer, dist_travelled, :fly, secs) do
    if reindeer.duration >= secs do
      dist_travelled + reindeer.speed * (reindeer.duration - secs)
    else
      distance_at(reindeer,
                  dist_travelled + reindeer.speed * reindeer.duration,
                  :rest, secs - reindeer.duration)
    end
  end
  defp distance_at(reindeer, dist_travelled, :rest, secs) do
    if reindeer.rest >= secs do
      dist_travelled
    else
      distance_at(reindeer,
                  dist_travelled,
                  :fly, secs - reindeer.rest)
    end
  end

  # ================ method two ================

  # Yes I could count down instead of up but this helps with debugging
  # defp race(reindeer, t, t), do: reindeer
  # defp race(reindeer, t, race_duration) do
  #   reindeer = reindeer |> Enum.map(&update/1)
  #   max_dist = reindeer |> Enum.map(&(&1.dist_travelled)) |> Enum.max
  #   reindeer = reindeer |> Enum.map(&(give_points(&1, max_dist)))
  #   race(reindeer, t+1, race_duration)
  # end
  defp race(reindeer, 0), do: reindeer
  defp race(reindeer, secs) do
    reindeer = reindeer |> Enum.map(&update/1)
    max_dist = reindeer |> Enum.map(&(&1.dist_travelled)) |> Enum.max
    reindeer = reindeer |> Enum.map(&(give_points(&1, max_dist)))
    race(reindeer, secs-1)
  end

  defp update(%Day14{state: :flying, time_in_state: t, duration: t} = reindeer) do
    %{reindeer | state: :resting, time_in_state: 1}
  end
  defp update(%Day14{state: :flying, time_in_state: t, duration: d} = reindeer) do
      %{reindeer | dist_travelled: reindeer.dist_travelled + reindeer.speed,
        time_in_state: t + 1}
  end
  defp update(%Day14{state: :resting, time_in_state: t, rest: t} = reindeer) do
    %{reindeer | state: :flying, time_in_state: 1,
      dist_travelled: reindeer.dist_travelled + reindeer.speed}
  end
  defp update(%Day14{state: :resting, time_in_state: t, rest: r} = reindeer) do
    %{reindeer | time_in_state: reindeer.time_in_state + 1}
  end

  defp give_points(%Day14{dist_travelled: d, points: p} = reindeer, max_dist)
  when d == max_dist do
    %{reindeer | points: p + 1}
  end
  defp give_points(reindeer, _), do: reindeer
end

# Day14.max_dist
# # => 2640

# Day14.winning_points
# # => 1102, 1635 is too high, 519 too low
