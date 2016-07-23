defmodule Hookah.MazeChannel do
  use Hookah.Web, :channel

  def join("maze", params, socket) do
    {:ok, initial_world, socket}
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
