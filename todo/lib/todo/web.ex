defmodule Todo.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.add_entry(%{title: title, date: date})

    ok(conn)
  end

  post "/update_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    entry_id = conn.params |> Map.fetch!("id") |> String.to_integer()
    new_entry = Map.take(conn.params, [:id, :date, :title])
    update_fn = fn e -> Map.merge(e, new_entry) end

    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.update_entry(entry_id, update_fn)

    ok(conn)
  end

  post "/delete_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    entry_id = conn.params |> Map.fetch!("id") |> String.to_integer()

    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.delete_entry(entry_id)

    ok(conn)
  end

  post "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    formatted_entries =
      list_name
      |> Todo.Cache.server_process()
      |> Todo.Server.entries(date)
      |> Enum.map(&"#{&1.date} #{&1.title}")
      |> Enum.join("\n")

    ok(conn, formatted_entries)
  end

  def child_spec(_arg) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      options: [port: 5454],
      plug: __MODULE__
    )
  end

  defp ok(conn, text \\ "OK") do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, text)
  end
end
