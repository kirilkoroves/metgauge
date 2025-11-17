# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :metgauge,
  ecto_repos: [Metgauge.Repo]

# Configures the endpoint
config :metgauge, MetgaugeWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MetgaugeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Metgauge.PubSub,
  live_view: [signing_salt: "Eqh3lRWi"]

config :metgauge, :gettext,
  default_locale: "en",
  locales: ["en", "ja", "zh_TW"]

config :ex_cldr,
  default_locale: "en",
  default_backend: Metgauge.Cldr

config :ex_money,
  default_cldr_backend: Metgauge.Cldr

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :metgauge, Metgauge.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

#config :phoenix_inline_svg, dir: "./priv/static/assets/svg"

config :ex_heroicons, type: "outline"


# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.1.6",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  base_path: "/oauth"

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"


config :metgauge, firebase_api_key: "AAAAyXZcdiQ:APA91bFciOpOTbc2ZimVEzzGI-yojI1OwzMjVZ6tqY3ZWJTx9Ehq3XffuNDxzjHHt-zdO3zFtnKzN4b-w_Fnrqp7GSBEj9USDXLKzpwOAMBo93_F_FRQdOenMPKQvRBBqjHTZzOtUxpX"


config :metgauge, azure_image_dir: "images", azure_video_dir: "videos", azure_file_dir: "files"

config :metgauge, percentage_from_seller: 10, percentage_from_buyer: 5, price_credit: 5, price_subscription: 500

config :metgauge, courses_server_url: "https://thproduction.blob.core.windows.net/$web/"

config :porcelain, driver: Porcelain.Driver.Basic
