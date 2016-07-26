use Mix.Config

config :hookah, Hookah.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: System.get_env("HOST"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :hookah, oauth_client_id: System.get_env("OAUTH_CLIENT_ID")
config :hookah, oauth_client_secret: System.get_env("OAUTH_CLIENT_SECRET")

config :hookah, Hookah.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :logger, level: :info
