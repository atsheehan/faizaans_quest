defmodule Hookah.MazeChannel do
  use Hookah.Web, :channel

  def join("maze", params, socket) do
    resp = %{hello: "world"}
    {:ok, resp, socket}
  end
end
