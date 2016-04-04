defmodule Metex.Worker do
  
  @moduledoc """
  Retrieve temperatures in one or more cities.
  """

  @base_url "http://api.openweathermap.org/data/2.5/weather?q="
  @kelvin_offset 273.15

  def temperatures_of(locations) do
    coord_pid = spawn(Metex.Coordinator, :loop, [[], length(locations)])
    locations |> Enum.map(fn(loc) ->
      worker_pid = spawn(Metex.Worker, :loop, [])
      send(worker_pid, {coord_pid, loc})
    end)
  end

  def temperature_of(location) do
    result = url_for(location) |> HTTPoison.get |> parse_response
    case result do
      {:ok, temp} -> "#{location}: #{temp}°C"
      :error -> "#{location} not found"
    end
  end

  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})
    end
    loop
  end

  defp url_for(location) do
    @base_url <> location
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> Poison.decode! |> compute_temperature
  end
  defp parse_response(_), do: :error

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - @kelvin_offset) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  # defp celsius_to_farenheit(deg_c) do
  #   deg_c * (9.0 / 5.0) + 32.0
  # end
end
