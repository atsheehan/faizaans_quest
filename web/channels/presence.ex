defmodule Hookah.Presence do
  use Phoenix.Presence, otp_app: :hookah,
    pubsub_server: Hookah.PubSub
end
