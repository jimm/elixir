defmodule SimpleCache.EventLogger do
  use GenEvent.Behaviour

  alias SimpleCache.Event

  # ================ API ================

  def add_handler do
    Event.add_handler(__MODULE__, [])
  end

  def delete_handler do
    Event.delete_handler(__MODULE__, [])
  end

  # ================ GenEvent ================

  def handle_event({:create, {key, val}}, state) do
    :error_logger.info_msg("create(#{inspect key}, #{inspect val})\n")
    {:ok, state}
  end

  def handle_event({:lookup, key}, state) do
    :error_logger.info_msg("lookup(#{inspect key})\n")
    {:ok, state}
  end

  def handle_event({:delete, key}, state) do
    :error_logger.info_msg("delete(#{inspect key})\n")
    {:ok, state}
  end

  def handle_event({:replace, {key, val}}, state) do
    :error_logger.info_msg("replace(#{inspect key}, #{inspect val})\n")
    {:ok, state}
  end

end
