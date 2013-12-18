defmodule Mix.Tasks.Install do
  use Mix.Task
  use SessionStore.Database


  @shortdoc "Create the database; --test creates a few test records"

  def run(args) do
    # This creates the mnesia schema, this has to be done on every node before
    # starting mnesia itself, the schema gets stored on disk based on the
    # `-mnesia` config, so you don't really need to create it every time.
    Amnesia.Schema.create

    # Once the schema has been created, you can start mnesia.
    Amnesia.start

    # When you call create/1 on the database, it creates a metadata table about
    # the database for various things, then iterates over the tables and creates
    # each one of them with the passed copying behaviour
    #
    # In this case it will keep a ram and disk copy on the current node.
    Database.create(disk: [node])

    # This waits for the database to be fully created.
    Database.wait

    if ["--test"] == args, do: create_test_records

    # Stop mnesia so it can flush everything and keep the data sane.
    Amnesia.stop
  end

  defp create_test_records do
    Amnesia.transaction do
      User.write(User[name: "Spongebob Squarepants"])
      User.write(User[name: "Patrick Starfish"])
      Project.write(Project[title: "Mnesia", description: "We are using this right now"])
      Project.write(Project[title: "Buggy", description: "Rubber baby buggy bumpers"])
      Contributor.write(Contributor[user_id: 1, title: "Mnesia"])
      Contributor.write(Contributor[user_id: 2, title: "Mnesia"])
      Contributor.write(Contributor[user_id: 1, title: "Buggy"])
    end
  end
end
