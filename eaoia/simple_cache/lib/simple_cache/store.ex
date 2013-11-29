use Amnesia

defdatabase SimpleCache.Store do

  def init(mnesia_node) do
    Amnesia.master_nodes [mnesia_node]
    Amnesia.Schema.create([mnesia_node])
    Amnesia.start
    create(disk: [mnesia_node]) # where to keep copies on disk
  end

  # Could use deftablep, but that inhibits IEx testing.
  deftable KeyToPid, [:key, :pid], index: :pid

  def insert(key, pid) do
    KeyToPid[key: key, pid: pid].write!
  end

  def lookup(key) do
    case KeyToPid.read!(key) do
      nil ->
        {:error, :not_found}
      ktp ->
        case pid_alive?(ktp.pid) do
          true -> {:ok, ktp.pid}
          false -> {:error, :not_found}
        end
    end
  end

  def delete(pid) do
    KeyToPid.delete(:pid, pid)
  end

  defp pid_alive?(pid) when node(pid) == :erlang.node() do
    Process.alive?(pid)
  end

  defp pid_alive?(pid) do
    np = :erlang.node(pid)
    Enum.member?(Node.list(), np) and :rpc.call(np, :erlang, :is_process_alive, [pid]) == true
  end
end
