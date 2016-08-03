defmodule Hookah.MazeChannel do
  use Hookah.Web, :channel

  alias Hookah.Maze
  alias Hookah.MazeRegistry

  def join("mazes:" <> maze_id, _params, socket) do
    case MazeRegistry.lookup(maze_id) do
      {:ok, pid} ->
        socket = assign(socket, :maze_pid, pid)
        world =
          Maze.join(pid, socket.assigns.user)
          |> add_player_id(socket)

        {:ok, serialize(world), socket}
      :error ->
        {:error, %{reason: "Cannot find maze with ID: #{maze_id}"}}
    end
  end

  def terminate(_reason, socket) do
    Maze.leave(socket.assigns.maze_pid, socket.assigns.user.id)
    :ok
  end

  intercept ["update"]

  def handle_out("update", world, socket) do
    push socket, "update", add_player_id(serialize(world), socket)
    {:noreply, socket}
  end

  def handle_in("move_left", params, socket), do: move(:left, params, socket)
  def handle_in("move_right", params, socket), do: move(:right, params, socket)
  def handle_in("move_up", params, socket), do: move(:up, params, socket)
  def handle_in("move_down", params, socket), do: move(:down, params, socket)

  defp move(direction, _params, socket) do
    player_id = socket.assigns.user.id
    maze_pid = socket.assigns.maze_pid

    world = Maze.move(maze_pid, player_id, direction)
    broadcast!(socket, "update", world)
    {:noreply, socket}
  end

  defp add_player_id(world, socket) do
    Map.put(world, :player_id, socket.assigns.user.id)
  end

  defp serialize(world) do
    cells = Enum.flat_map(world.cells, fn {{row, col}, cell} -> [row, col, cell] end)
    players = Map.values(world.players)

    world
    |> Map.put(:cells, cells)
    |> Map.put(:players, players)
  end
end
