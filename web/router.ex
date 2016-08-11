defmodule Hookah.Router do
  use Hookah.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Hookah do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/mazes", MazeController, only: [:index, :show]

    get "/app/*path", AppController, :index
    get "/auth/sign_in", SessionController, :sign_in
    get "/auth/sign_out", SessionController, :sign_out
    get "/auth/github/callback", SessionController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", Hookah do
  #   pipe_through :api
  # end
end
