defmodule EmysqlTest do

  def run(opts) do
    opts = [host: 'localhost',
            port: 3306,
            size: 1,
            database: 'test',
            encoding: :utf8]
      |> Keyword.merge opts
      |> Enum.map fn({k,v}) -> {k, bin_to_ch(v)} end

    :emysql.add_pool(:test_pool, opts)

    :emysql.execute(:test_pool, "drop table if exists foo")
    :emysql.execute(:test_pool, "create table foo (id int not null primary key) engine=innodb")
    1..10 |> Enum.map(fn(i) -> :emysql.execute(:test_pool, "insert into foo values (#{i})") end)
    results = :emysql.execute(:test_pool, "select count(*) as count from foo")
      |> result_to_map
    IO.puts "number of foo rows: #{hd(results)[:count]}"
    :emysql.execute(:test_pool, "drop table foo")
  end

  defp bin_to_ch(val) when is_binary(val), do: String.to_char_list(val)
  defp bin_to_ch(val), do: val

  def result_to_map({:result_packet, _, fields, rows, _}) do
    field_names = fields
                    |> Enum.map(fn({:field, _, _, _, _, _, name, _, _, _, _, _, _, _, _}) ->
                                    name
                                end)
    rows
      |> Enum.map(&row_to_map(&1, field_names))
  end

  defp row_to_map(row, field_names) do
    field_names
      |> Enum.map(&String.to_atom(&1))
      |> Enum.zip(row)
      |> Enum.into(%{})
  end
end
