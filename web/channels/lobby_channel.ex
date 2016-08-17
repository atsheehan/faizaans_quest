defmodule Hookah.LobbyChannel do
  use Hookah.Web, :channel

  alias Hookah.Presence

  def join("lobby", _params, socket) do
    mazes = Hookah.MazeRegistry.list_mazes
    send(self, :after_join)
    {:ok, mazes, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user.id,
      %{username: socket.assigns.user.username})
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end
end
