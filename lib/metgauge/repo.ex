defmodule Metgauge.Repo do
  use Ecto.Repo,
    otp_app: :metgauge,
    adapter: Ecto.Adapters.Postgres

  use Scrivener
end
