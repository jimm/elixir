defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  def home(conn, _params) do
    conn
    |> put_flash(:error, "Let's pretend we have an error.")
    |> render(:home)
  end
end
