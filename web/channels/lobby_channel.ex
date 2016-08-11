defmodule Hookah.LobbyChannel do
  use Hookah.Web, :channel

  alias Hookah.MazeRegistry

  def join("lobby", _params, socket) do
    mazes = Hookah.MazeRegistry.list_mazes
    {:ok, mazes, socket}
  end
end
