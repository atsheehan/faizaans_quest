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
      |> Map.put(:players, %{})

    {:ok, world}
  end

  def handle_call({:move, player_id, direction}, _from, world) do
    {new_world, affected_players} = do_move(world, player_id, direction)
    {:reply, {viewable_by(player_id, new_world), affected_players}, new_world}
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

  defp player_exists?(%{players: players}, player_id) do
    Map.has_key?(players, player_id)
  end

  @visibility 5

  defp viewable_by(player_id, world = %{cells: cells, players: players}) do
    %{position: %{x: player_col, y: player_row}} = find_player(world, player_id)

    visible_cells = for row <- (player_row - @visibility)..(player_row + @visibility),
      col <- (player_col - @visibility)..(player_col + @visibility),
      do: {row, col}

    visible_players = Enum.filter(players, fn {_, %{position: position}} ->
      Enum.member?(visible_cells, {position.y, position.x})
    end)

    %{world | cells: Map.take(cells, visible_cells), players: Map.new(visible_players)}
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

    original_position = player.position
    new_position = shift_position(original_position, direction)

    if passable?(world, new_position) do
      affected_players = find_players_in_range_of(world,
        [original_position, new_position])

      world = update_player(world, %{player|position: new_position})
      {world, affected_players}
    else
      {world, []}
    end
  end

  defp find_players_in_range_of(%{players: players}, positions) do
    Enum.filter(players, fn {_id, %{position: %{y: player_row, x: player_col}}} ->
      Enum.any?(positions, fn %{y: row, x: col} ->
        row <= (player_row + @visibility) && row >= (player_row - @visibility) &&
        col <= (player_col + @visibility) && col >= (player_col - @visibility)
      end)
    end)
  end

  defp find_player(%{players: players}, player_id) do
    players[player_id]
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
    updated_players = %{players | player_id => new_player}
    %{world|players: updated_players}
  end

  defp passable?(%{cells: cells}, %{x: x, y: y}) do
    cells[{y, x}] == 0
  end

  defp add_player(world = %{players: players}, %{id: player_id, username: username}) do
    new_player = %{id: player_id, username: username, position: %{x: 1, y: 1}}
    updated_players = Map.put(players, player_id, new_player)
    %{world | players: updated_players}
  end

  defp remove_player(world = %{players: players}, player_id) do
    %{world | players: Map.delete(players, player_id)}
  end
end
