defmodule Metgauge.MixProject do
  use Mix.Project

  def project do
    [
      app: :metgauge,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [] ++ Mix.compilers(),
      start_permanent: Mix.env() in [:prod, :staging],
      aliases: aliases(),
      deps: deps(),
      elixirc_options: [
        warnings_as_errors: false
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Metgauge.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.6.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:phoenix_inline_svg, "~> 1.4"},
      {:floki, ">= 0.30.0"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "== 0.21.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:tzdata, "~> 1.1"},
      {:ex_money, "~> 5.12"},
      {:ex_money_sql, "~> 1.7"},
      #{:money, "~> 1.12"},
      {:ex_cldr, "~> 2.33"},
      {:ex_cldr_currencies, "~> 2.14"},
      {:ex_cldr_dates_times, "~> 2.0"},
      {:mogrify, "~> 0.9.1"},
      # Email notifier
      {:swoosh, "~> 1.8"},
      {:phoenix_swoosh, "~> 1.0"},
      {:gen_smtp, "~> 1.1.1"},
      # Require dependency for email notifier(don't change it to hockey, it will end up with can't pass AWS authentication)
      {:finch, "~> 0.13"},
      {:uuid, "~> 1.1" },
      {:sweet_xml, "~> 0.6"},
      {:timex, "~> 3.7.9"},
      {:slugify, "~> 1.3"},
      # CSS
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},

      # Type and syntax checking
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},

      # Authentication
      {:ueberauth, "~> 0.7"},
      {:ueberauth_google, "~> 0.10"},
      {:ueberauth_facebook, "~> 0.8"},
      {:language_list, "~> 2.0.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:qrcode_ex, "~> 0.1.0"},
      {:icalendar, "~> 1.1.0"},
      {:aws_signature, "~> 0.3"},
      {:cors_plug, "~> 3.0"},
      {:httpoison, "~> 1.8.0"},
      {:poison, "~> 3.1.0"},
      {:sched_ex, "~> 1.0"},
      {:con_cache, "~> 0.13"},
      {:countries, "~> 1.6"},
      {:number, "~> 1.0.1"},
      {:html_sanitize_ex, "~> 1.4"},
      {:azurex, "~> 1.0.0"},
      {:ex_image_info, "~> 0.2.4"},
      {:file_type, "~> 0.1.0"},
      {:erlport, "~> 0.9"},
      {:csv, "~> 2.3"},
      {:pdf_generator, ">=0.6.0" },
      {:porcelain, "~> 2.0"},
      {:recase, "~> 0.4"},
      {:scrivener_ecto, "~> 2.0"},
      {:ex_heroicons, "~> 2.0.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd --cd assets npm install", "svg"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      svg: [
        "cmd --cd assets npx svgr --out-dir js/svg --no-dimensions --ext jsx ../priv/static/svg"
      ],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "tailwind default --minify",
        # "cmd --cd assets node build.js --deploy",
        "svg",
        "cmd --cd assets npm run deploy",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
