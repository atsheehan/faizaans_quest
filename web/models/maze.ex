defmodule Hookah.Maze do
  use GenServer

  def get_world(pid), do: GenServer.call(pid, :get_world)

  def start_link do
    GenServer.start_link(__MODULE__, initial_world)
  end

  def init(initial_world) do
    {:ok, initial_world}
  end

  def handle_call(:get_world, _from, world) do
    {:reply, world, world}
  end

  defp initial_world do
    %{
      rows: 4,
      columns: 4,
      grid: [
        1, 1, 1, 1, 1, 0, 0, 1,
        1, 0, 0, 1, 1, 1, 1, 1
      ],
      player: %{x: 1, y: 1}
    };
  end
end
