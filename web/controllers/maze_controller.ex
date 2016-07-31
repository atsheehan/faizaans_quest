defmodule Hookah.MazeController do
  use Hookah.Web, :controller

  import Hookah.Auth, only: [authenticate: 2]
  plug :authenticate

  def index(conn, _params) do
    mazes = Hookah.MazeRegistry.list_mazes
    render(conn, "index.html", mazes: mazes)
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", user_token: user_token(conn), maze_id: id)
  end

  defp user_token(conn) do
    case {get_session(conn, :provider_id), get_session(conn, :username)} do
      {nil, _} -> nil
      {_, nil} -> nil
      {id, username} ->
        Phoenix.Token.sign(conn, "user socket", %{user_id: id, username: username})
    end
  end
end
