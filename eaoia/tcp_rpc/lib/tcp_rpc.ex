defmodule TcpRpc.State do
  defstruct port: 0, lsock: nil, request_count: 0
end

defmodule TcpRpc do

  @moduledoc """
  RPC over TCP server. This module defines a server process that listens for
  incoming TCP connections and allows the user to execute RPC commands via
  that TCP stream.
  """

  use Behaviour

  @server :tcp_rpc
  @default_port 1055

  # ================ API ================

  def start_link(), do: start_link(@default_port)

  def start_link(port) do
    :gen_server.start_link({:local, @server}, __MODULE__, port, [])
  end

  @doc "Returns the number of requests made to this server."
  def get_count(), do: :gen_server.call(@server, :get_count)

  @doc "Stops the server."
  def stop(), do: :gen_server.cast(@server, :stop)

  # ================ GenServer implementation ================

  def init(port) do
    {:ok, lsock} = :gen_tcp.listen(port, [active: true])
    {:ok, %TcpRpc.State{port: port, lsock: lsock}, 0}
  end

  def handle_call(:get_count, _from, state) do
    {:reply, state.request_count, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_info({:tcp, socket, raw_data}, state) do
    do_rpc(socket, raw_data)
    {:noreply, state.request_count(state.request_count+1)}
  end

  def handle_info(:timeout, state) do
    {:ok, _sock} = :gen_tcp.accept(state.lsock)
    {:noreply, state}
  end

  # ================ Internals ================

  defp do_rpc(socket, raw_data) do
    try do
      result = Code.eval_string(raw_data |> String.from_char_list! |> String.rstrip)
      :gen_tcp.send(socket, :io_lib.fwrite("~p~n", [result]))
    rescue
      err -> :gen_tcp.send(socket, :io_lib.fwrite("~p~n", [err]))
    end
  end
end
