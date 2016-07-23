defmodule Hookah.MazeChannel do
  use Hookah.Web, :channel

  def join("maze", _params, socket) do
    :timer.send_interval(5_000, :sync_world)
    {:ok, initial_world, socket}
  end

  def handle_info(:sync_world, socket) do
    broadcast!(socket, "update", initial_world)
    {:noreply, socket}
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
