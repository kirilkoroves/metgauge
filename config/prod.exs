import Config

# Configure your database
config :metgauge, Metgauge.Repo,
  username: "mover",
  password: "Skopje123$",
  hostname: "localhost",
  database: "mover",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :metgauge, MetgaugeWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  url: [host: "mover.cogini.com", port: 443, scheme: "https"],
  https: [
    port: 4001,
    cipher_suite: :strong,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem",
    protocol_options: [idle_timeout: 5_000_000]
  ],
  debug_errors: true,
  secret_key_base: "AkppvbDq/PX8VwZiYR1hyN9NVTGMQRHLxc4FA3b44bxzVdRsXGb+Xo8EZlUBDnmK",
  parsers: [parsers: [:urlencoded, :multipart, :json],
            accept: ["*/*"],
            json_decoder: Poison,
            length: 300_000_000]

config :metgauge, MetgaugeWeb.Endpoint, force_ssl: [hsts: true]
config :metgauge, MetgaugeWeb.Endpoint, server: true

config :metgauge, Metgauge.Mailer,
  #adapter: Swoosh.Adapters.Logger,
  adapter: Swoosh.Adapters.Local,
  level: :warning,
  log_full_email: true


# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "GOOGLE CLIENT ID",
  client_secret: "GOOGLE CLIENT SECRET"

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "579155513914821",
  client_secret: "982c9c2ff3d59b166e7f692690eb682b"

config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime