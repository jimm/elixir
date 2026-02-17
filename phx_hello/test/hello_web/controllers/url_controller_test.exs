defmodule HelloWeb.UrlControllerTest do
  use HelloWeb.ConnCase

  import Hello.UrlsFixtures
  alias Hello.Urls.Url

  @create_attrs %{
    link: "some link",
    title: "some title"
  }
  @update_attrs %{
    link: "some updated link",
    title: "some updated title"
  }
  @invalid_attrs %{link: nil, title: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all urls", %{conn: conn} do
      conn = get(conn, ~p"/api/urls")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create url" do
    test "renders url when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/urls", url: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/urls/#{id}")

      assert %{
               "id" => ^id,
               "link" => "some link",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/urls", url: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update url" do
    setup [:create_url]

    test "renders url when data is valid", %{conn: conn, url: %Url{id: id} = url} do
      conn = put(conn, ~p"/api/urls/#{url}", url: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/urls/#{id}")

      assert %{
               "id" => ^id,
               "link" => "some updated link",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, url: url} do
      conn = put(conn, ~p"/api/urls/#{url}", url: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete url" do
    setup [:create_url]

    test "deletes chosen url", %{conn: conn, url: url} do
      conn = delete(conn, ~p"/api/urls/#{url}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/urls/#{url}")
      end
    end
  end

  defp create_url(_) do
    url = url_fixture()

    %{url: url}
  end
end
