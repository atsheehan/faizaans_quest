defmodule Hookah.MazeChannel do
  use Hookah.Web, :channel

  def join("maze", _params, socket) do
    :timer.send_interval(5_000, :sync_world)
    initial_world = Hookah.Maze.join(socket.assigns.user_id)
    {:ok, initial_world, socket}
  end

  def handle_info(:sync_world, socket) do
    world = Hookah.Maze.get_world
    broadcast!(socket, "update", world)
    {:noreply, socket}
  end

  def handle_in("move_left", params, socket), do: move(:left, params, socket)
  def handle_in("move_right", params, socket), do: move(:right, params, socket)
  def handle_in("move_up", params, socket), do: move(:up, params, socket)
  def handle_in("move_down", params, socket), do: move(:down, params, socket)

  defp move(direction, _params, socket) do
    player_id = socket.assigns.user_id
    world = Hookah.Maze.move(player_id, direction)
    broadcast!(socket, "update", world)
    {:noreply, socket}
  end
end
