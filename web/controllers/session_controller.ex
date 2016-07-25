defmodule Hookah.SessionController do
  use Hookah.Web, :controller

  import Hookah.Auth, only: [authenticate: 2]
  plug :authenticate when action in [:sign_out]

  @oauth_login_url "https://github.com/login/oauth/authorize"
  @oauth_access_url "https://github.com/login/oauth/access_token"
  @user_details_url "https://api.github.com/user"

  def sign_in(conn, _params) do
    redirect(conn, external: oauth_login_url)
  end

  def sign_out(conn, _params) do
    conn
    |> delete_session(:provider_id)
    |> delete_session(:provider_name)
    |> delete_session(:username)
    |> redirect(to: "/")
  end

  def callback(conn, %{"code" => code}) do
    resp = HTTPoison.post!(oauth_access_token_url(code), "", %{"Accept" => "application/json"})
    %{"access_token" => access_token} = Poison.Parser.parse!(resp.body)

    resp = HTTPoison.get!(@user_details_url, %{"Authorization" => "token #{access_token}"})
    %{"id" => id, "login" => username} = Poison.Parser.parse!(resp.body)

    put_session(conn, :provider_id, id)
    |> put_session(:provider_name, "github")
    |> put_session(:username, username)
    |> redirect(to: "/")
  end

  defp oauth_access_token_url(code) do
    merge_url_params(@oauth_access_url, %{client_id: client_id, client_secret: client_secret, code: code})
  end

  defp oauth_login_url do
    merge_url_params(@oauth_login_url, %{client_id: client_id})
  end

  defp merge_url_params(url, params) do
    URI.parse(url)
    |> Map.put(:query, URI.encode_query(params))
    |> URI.to_string
  end

  defp client_id, do: Application.fetch_env!(:hookah, :oauth_client_id)
  defp client_secret, do: Application.fetch_env!(:hookah, :oauth_client_secret)
end
