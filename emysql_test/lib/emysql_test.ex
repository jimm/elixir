defmodule EmysqlTest do

  @test_table "emysql_test"

  @doc """
  Create a test table, insert some records, print the number of records,
  and delete the table.

  See :emysql.add_pool/2 for possible keyword args.
  """
  def run(opts \\ []) do
    opts = [database: 'test']
      |> Keyword.merge opts
      |> Enum.map fn({k,v}) -> {k, bin_to_ch(v)} end
    :emysql.add_pool(:test_pool, opts)
    create_test_table()
    create_test_data()

    rows = execute(:test_pool, """
      select count(*) as count, max(id) as max
      from #{@test_table}
    """)

    row = hd(rows)
    IO.puts "number of #{@test_table} rows: #{row["count"]}"
    IO.puts "max id in #{@test_table}: #{row["max"]}"

    drop_test_table()
  end

  # Execute SQL and return the results as a list of maps.
  defp execute(conn, sql) do
    :emysql.execute(conn, sql) |> results_to_maps
  end

  # Convert string to char list.
  defp bin_to_ch(val) when is_binary(val), do: String.to_char_list(val)
  defp bin_to_ch(val), do: val

  defp create_test_table do
    drop_test_table()
    :emysql.execute(:test_pool, """
      create table #{@test_table} (
        id int not null primary key
      ) engine=innodb
      """)
  end

  defp create_test_data do
    f = fn(i) ->
            :emysql.execute(:test_pool, "insert into #{@test_table} values (#{i})")
        end
    1..10 |> Enum.map &f.(&1 * 2)
  end

  defp drop_test_table do
    :emysql.execute(:test_pool, "drop table if exists #{@test_table}")
  end

  # Convert Emysql results to a list of maps.
  defp results_to_maps(results) do
    results
      |> :emysql.as_proplist
      |> Enum.map(&(Enum.into(&1, %{})))
  end
end
