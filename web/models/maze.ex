defmodule Hookah.Maze do
  use GenServer

  def get_world(pid, player_id) do
    GenServer.call(pid, {:get_world, player_id})
  end

  def join(pid, player = %{id: _, username: _}) do
    GenServer.call(pid, {:join, player})
  end

  def leave(pid, player_id) do
    GenServer.cast(pid, {:leave, player_id})
  end

  def move(pid, player_id, direction) do
    GenServer.call(pid, {:move, player_id, direction})
  end

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    world =
      generate_maze(20, 20)
      |> Map.put(:players, [])

    {:ok, world}
  end

  def handle_call({:move, player_id, direction}, _from, world) do
    new_world = do_move(world, player_id, direction)
    {:reply, viewable_by(player_id, new_world), new_world}
  end

  def handle_call({:join, player = %{id: player_id, username: _}}, _from, world) do
    new_world = if !player_exists?(world, player_id) do
      add_player(world, player)
    else
      world
    end

    {:reply, viewable_by(player_id, new_world), new_world}
  end

  def handle_call({:get_world, player_id}, _from, world) do
    {:reply, viewable_by(player_id, world), world}
  end

  def handle_cast({:leave, player_id}, world) do
    new_world = if player_exists?(world, player_id) do
      remove_player(world, player_id)
    else
      world
    end

    {:noreply, new_world}
  end

  defp player_exists?(world, player) do
    !!find_player(world, player)
  end

  defp viewable_by(player_id, world = %{cells: cells}) do
    %{position: %{x: player_col, y: player_row}} = find_player(world, player_id)

    range = 5

    visible_cells = for row <- (player_row - range)..(player_row + range),
      col <- (player_col - range)..(player_col + range),
      do: {row, col}

    %{world | cells: Map.take(cells, visible_cells)}
  end

  defp generate_maze(rows, columns) do
    width = 2 * columns + 1
    height = 2 * rows + 1

    cells = for row <- (0..rows - 1), col <- (0..columns - 1), do: {2 * row + 1, 2 * col + 1}

    open_cells = Enum.reduce(cells, MapSet.new, fn {row, col}, open_cells ->
      neighboring_cells = [{row + 2, col}, {row, col + 2}]
      |> Enum.reject(fn {row, col} -> row >= height || col >= width end)

      if !Enum.empty?(neighboring_cells) do
        target_cell = Enum.random(neighboring_cells)
        {target_row, target_col} = target_cell

        cells_to_open = for r <- (row..target_row), c <- (col..target_col), do: {r, c}

        Enum.reduce(cells_to_open, open_cells, fn cell, open_cells ->
          MapSet.put(open_cells, cell)
        end)
      else
        open_cells
      end
    end)

    cells = for row <- (0..height - 1),
      col <- (0..width - 1),
      into: %{},
      do: {{row, col}, (if MapSet.member?(open_cells, {row, col}), do: 0, else: 1)}

    %{cells: cells}
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

  defp passable?(world = %{cells: cells}, pos = %{x: x, y: y}) do
    cells[{y, x}] == 0
  end

  defp add_player(world = %{players: players}, %{id: player_id, username: username}) do
    new_player = %{id: player_id, username: username, position: %{x: 1, y: 1}}
    new_players = [new_player | players]
    %{world|players: new_players}
  end

  defp remove_player(world = %{players: players}, player_id) do
    new_players = Enum.reject(players, fn player -> player.id == player_id end)
    %{world|players: new_players}
  end
end
