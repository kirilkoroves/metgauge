defmodule Metgauge.Presence do
  use Phoenix.Presence,
    otp_app: :metgauge,
    pubsub_server: Metgauge.PubSub
end