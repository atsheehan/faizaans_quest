defmodule Hookah.Maze do
  use GenServer

  def get_world(pid \\ Hookah.Maze), do: GenServer.call(pid, :get_world)

  def join(pid \\ Hookah.Maze, player_id) do
    GenServer.call(pid, {:join, player_id})
  end

  def move(pid \\ Hookah.Maze, player_id, direction) do
    GenServer.call(pid, {:move, player_id, direction})
  end

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, initial_world, name: name)
  end

  def init(initial_world) do
    {:ok, initial_world}
  end

  def handle_call({:move, player_id, direction}, _from, world) do
    new_world = do_move(world, player_id, direction)
    {:reply, new_world, new_world}
  end

  def handle_call({:join, player_id}, _from, world) do
    new_world = if !player_exists?(world, player_id) do
      add_player(world, player_id)
    else
      world
    end

    {:reply, new_world, new_world}
  end

  def handle_call(:get_world, _from, world) do
    {:reply, world, world}
  end

  defp player_exists?(world, player) do
    !!find_player(world, player)
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
      players: []
    };
  end

  defp do_move(world, player_id, direction) do
    player = find_player(world, player_id)
    new_position = shift_position(player.position, direction)

    if passable?(world, new_position) do
      update_player(world, %{player|position: new_position})
    else
      world
    end
  end

  defp find_player(%{players: players}, player_id) do
    Enum.find(players, fn player -> player.id == player_id end)
  end

  defp shift_position(position, direction) do
    case direction do
      :left -> %{x: position.x - 1, y: position.y}
      :right -> %{x: position.x + 1, y: position.y}
      :up -> %{x: position.x, y: position.y - 1}
      :down -> %{x: position.x, y: position.y + 1}
    end
  end

  defp update_player(world = %{players: players}, new_player = %{id: player_id}) do
    index = Enum.find_index(players, fn player -> player.id == player_id end)
    updated_players = List.replace_at(players, index, new_player)
    %{world|players: updated_players}
  end

  defp passable?(world = %{grid: grid}, position) do
    Enum.at(grid, index(world, position)) == 0
  end

  defp index(%{columns: columns}, %{x: x, y: y}) do
    (y * columns) + x
  end

  defp add_player(world = %{players: players}, player_id) do
    new_player = %{id: player_id, position: %{x: 1, y: 1}}
    new_players = [new_player | players]
    %{world|players: new_players}
  end
end
