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
    case direction do
      :left -> %{world|player: %{world.player|x: world.player.x - 1}}
      :right -> %{world|player: %{world.player|x: world.player.x + 1}}
      :up -> %{world|player: %{world.player|y: world.player.y - 1}}
      :down -> %{world|player: %{world.player|y: world.player.y + 1}}
    end
  end
end
