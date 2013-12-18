defmodule Mix.Tasks.Uninstall do
  use Mix.Task
  use SessionStore.Database

  @shortdoc "Destroy the database"

  def run(_) do
    # Start mnesia, or we can't do much.
    Amnesia.start

    # Destroy the database.
    SessionStore.Database.destroy

    # Stop mnesia, so it flushes everything.
    Amnesia.stop

    # Destroy the schema for the node.
    Amnesia.Schema.destroy
  end
end
