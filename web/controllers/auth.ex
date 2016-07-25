defmodule Hookah.Auth do
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def authenticate(conn, _opts) do
    if Plug.Conn.get_session(conn, :provider_id) do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: "/")
      |> Plug.Conn.halt()
    end
  end
end
