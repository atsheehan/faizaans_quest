defmodule Hookah.AppController do
  use Hookah.Web, :controller

  import Hookah.Auth, only: [authenticate: 2]
  plug :authenticate

  def index(conn, _params) do
    render(conn, "index.html", user_token: user_token(conn))
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
