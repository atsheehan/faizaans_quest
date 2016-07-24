defmodule Hookah.MazeChannel do
  use Hookah.Web, :channel

  def join("maze", _params, socket) do
    :timer.send_interval(5_000, :sync_world)
    {:ok, pid} = Hookah.Maze.start_link
    initial_world = Hookah.Maze.get_world(pid)
    socket = assign(socket, :maze_pid, pid)
    {:ok, initial_world, socket}
  end

  def handle_info(:sync_world, socket) do
    pid = socket.assigns[:maze_pid]
    world = Hookah.Maze.get_world(pid)
    broadcast!(socket, "update", world)
    {:noreply, socket}
  end

  def handle_in("move_left", params, socket), do: move(:left, params, socket)
  def handle_in("move_right", params, socket), do: move(:right, params, socket)
  def handle_in("move_up", params, socket), do: move(:up, params, socket)
  def handle_in("move_down", params, socket), do: move(:down, params, socket)

  defp move(direction, _params, socket) do
    pid = socket.assigns[:maze_pid]
    world = Hookah.Maze.move(pid, direction)
    broadcast!(socket, "update", world)
    {:noreply, socket}
  end
end
