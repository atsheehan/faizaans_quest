defmodule Hookah.Maze do
  use GenServer

  def get_world(pid \\ Hookah.Maze), do: GenServer.call(pid, :get_world)

  def move(pid \\ Hookah.Maze, direction) do
    GenServer.call(pid, {:move, direction})
  end

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, initial_world, name: name)
  end

  def init(initial_world) do
    {:ok, initial_world}
  end

  def handle_call({:move, direction}, _from, world) do
    new_world = do_move(world, direction)
    {:reply, new_world, new_world}
  end

  def handle_call(:get_world, _from, world) do
    {:reply, world, world}
  end

  defp initial_world do
    %{
      rows: 4,
      columns: 4,
      grid: [
        1, 1, 1, 1,
        1, 0, 0, 1,
        1, 0, 0, 1,
        1, 1, 1, 1
      ],
      player: %{x: 1, y: 1}
    };
  end

  defp do_move(world, direction) do
    new_position = move_player(world.player, direction)

    if passable?(world, new_position) do
      %{world|player: new_position}
    else
      world
    end
  end

  defp move_player(position, direction) do
    case direction do
      :left -> %{x: position.x - 1, y: position.y}
      :right -> %{x: position.x + 1, y: position.y}
      :up -> %{x: position.x, y: position.y - 1}
      :down -> %{x: position.x, y: position.y + 1}
    end
  end

  def passable?(world = %{grid: grid}, position) do
    Enum.at(grid, index(world, position)) == 0
  end

  def index(%{columns: columns}, %{x: x, y: y}) do
    (y * columns) + x
  end
end
