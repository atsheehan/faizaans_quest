defmodule Hookah.LayoutView do
  use Hookah.Web, :view

  def user_signed_in?(conn) do
    !!Plug.Conn.get_session(conn, :provider_id)
  end

  def current_username(conn) do
    Plug.Conn.get_session(conn, :username)
  end
end
