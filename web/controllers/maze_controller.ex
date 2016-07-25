defmodule Hookah.MazeController do
  use Hookah.Web, :controller

  import Hookah.Auth, only: [authenticate: 2]
  plug :authenticate

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
