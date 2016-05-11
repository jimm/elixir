defmodule Blitzy.CLI do
  require Logger

  def main(args) do
    init_nodes
    args |> parse_args |> process_options([Node.self | Node.list])
  end

  defp init_nodes do
    Application.get_env(:blitzy, :master_node) |> Node.start
    Application.get_env(:blitzy, :slave_nodes) |> Enum.each(&Node.connect(&1))
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests],
      strict: [request: :integer])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n], [url], []} ->
        run(n, url, nodes)
      _ ->
        usage
    end
  end

  defp run(num_requests, url, nodes) do
    Logger.info "Pummelling #{url} with #{num_requests} requests"
    total_nodes = length(nodes)
    req_per_node = div(num_requests, total_nodes)

    nodes
    |> Enum.flat_map(fn node ->
      1..req_per_node |> Enum.map(fn _ ->
      Task.Supervisor.async({Blitzy.TasksSupervisor, node},
        Blitzy.Worker, :start, [url])
      end)
    end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> Blitzy.parse_results
  end

  defp usage do
    IO.puts """
    usage: blitzy -n requests url

    options:
    -n, --requests      Number of requests
    """
  end
end
