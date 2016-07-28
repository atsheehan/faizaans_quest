defmodule Hookah.MazeChannel do
  use Hookah.Web, :channel

  def join("maze", _params, socket) do
    :timer.send_interval(5_000, :sync_world)
    initial_world =
      Hookah.Maze.join(socket.assigns.user)
      |> add_player_id(socket)
    {:ok, initial_world, socket}
  end

  def terminate(_reason, socket) do
    Hookah.Maze.leave(socket.assigns.user.id)
    world = Hookah.Maze.get_world
    broadcast!(socket, "update", world)
    :ok
  end

  def handle_info(:sync_world, socket) do
    world = Hookah.Maze.get_world
    broadcast!(socket, "update", world)
    {:noreply, socket}
  end

  intercept ["update"]

  def handle_out("update", world, socket) do
    push socket, "update", add_player_id(world, socket)
    {:noreply, socket}
  end

  def handle_in("move_left", params, socket), do: move(:left, params, socket)
  def handle_in("move_right", params, socket), do: move(:right, params, socket)
  def handle_in("move_up", params, socket), do: move(:up, params, socket)
  def handle_in("move_down", params, socket), do: move(:down, params, socket)

  defp move(direction, _params, socket) do
    player_id = socket.assigns.user.id
    world = Hookah.Maze.move(player_id, direction)
    broadcast!(socket, "update", world)
    {:noreply, socket}
  end

  defp add_player_id(world, socket) do
    Map.put(world, :player_id, socket.assigns.user.id)
  end
end
