defmodule Hookah.MazeRegistry do
  use GenServer

  def list_mazes(pid \\ Hookah.MazeRegistry) do
    GenServer.call(pid, :list)
  end

  def lookup(pid \\ Hookah.MazeRegistry, id) do
    GenServer.call(pid, {:lookup, id})
  end

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    {:ok, start_mazes(10, initial_state)}
  end

  def handle_call(:list, _from, mazes = {ids, _}) do
    {:reply, Map.keys(ids), mazes}
  end

  def handle_call({:lookup, id}, _from, mazes = {ids, _}) do
    {:reply, Map.fetch(ids, id), mazes}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {ids, refs}) do
    {id, refs} = Map.pop(refs, ref)
    ids = Map.delete(ids, id)
    {:noreply, {ids, refs}}
  end

  defp start_maze({ids, refs}) do
    {:ok, pid} = Hookah.Maze.start_link
    id = generate_id
    ref = Process.monitor(pid)
    refs = Map.put(refs, ref, id)
    ids = Map.put(ids, id, pid)
    {ids, refs}
  end

  defp generate_id, do: UUID.uuid4(:hex)
  defp initial_state, do: {%{}, %{}}

  defp start_mazes(count, state) do
    Enum.reduce(0..count, state, fn _, state ->
      start_maze(state)
    end)
  end
end
