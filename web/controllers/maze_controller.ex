defmodule Hookah.MazeController do
  use Hookah.Web, :controller

  import Hookah.Auth, only: [authenticate: 2]
  plug :authenticate

  def index(conn, _params) do
    conn
    |> assign(:user_token, user_token(conn))
    |> render("index.html")
  end

  defp user_token(conn) do
    case get_session(conn, :provider_id) do
      nil -> nil
      id -> Phoenix.Token.sign(conn, "user socket", id)
    end
  end
end
