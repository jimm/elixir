defmodule MariaexTest do

  @test_table "mariaex_test"

  @doc """
  Create a test table, insert some records, select some data, and delete the
  table.

  See :mariaex.add_pool/2 for possible keyword args.
  """
  def run(opts \\ [database: "test", username: "root"]) do
    {:ok, conn} = Mariaex.Connection.start_link(opts)
    create_test_table(conn)
    create_test_data(conn)

    rows = execute(conn, "select count(*) as count, max(id) as max from #{@test_table}")
    row = hd(rows)
    IO.puts "number of #{@test_table} rows: #{row["count"]}"
    IO.puts "max id in #{@test_table}: #{row["max"]}"

    drop_test_table(conn)
  end

  # Execute SQL and return the result. If it's a select statement, returns a
  # list of maps. Otherwise, return the raw %Mariaex.Result.
  defp execute(conn, sql) do
    {:ok, result} = Mariaex.Connection.query(conn, sql)
    if result.command == :select do
      if result.rows == nil do
        []
      else
        # Row data comes back as tuples. Turn it into a map with column
        # names as keys.
        foo = result.rows
        |> Enum.map(fn(row) ->
          Enum.zip(result.columns, Tuple.to_list(row))
          |> Enum.into(%{})
        end)
        foo
      end
    else
      result
    end
  end

  defp create_test_table(conn) do
    drop_test_table(conn)
    execute(conn, """
      create table #{@test_table} (
        id int not null primary key
      ) engine=innodb
      """)
  end

  defp create_test_data(conn) do
    f = fn(i) ->
            execute(conn, "insert into #{@test_table} values (#{i})")
        end
    1..10 |> Enum.map &f.(&1 * 2)
  end

  defp drop_test_table(conn) do
    execute(conn, "drop table if exists #{@test_table}")
  end
end
