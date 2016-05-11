defmodule Blitzy.Worker do
  use Timex
  require Logger

  def start(url) do
    IO.puts "#{name} started"
    {tstamp, response} = Time.measure(fn -> HTTPoison.get(url) end)
    handle_response({Time.to_msecs(tstamp), response})
  end

  defp handle_response({msecs, {:ok, %HTTPoison.Response{status_code: code}}})
  when code >= 200 && code <= 304 do
    Logger.info "#{name} completed in #{msecs} msecs"
    {:ok, msecs}
  end

  defp handle_response({_, {:error, reason}}) do
    Logger.info "#{name} error due to #{inspect reason}"
    {:error, reason}
  end

  defp handle_response({_, _}) do
    Logger.info "#{name} errored out}"
    {:error, :unknown}
  end

  defp name do
    "worker [#{node}-#{inspect self}]"
  end
end
