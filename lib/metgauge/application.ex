defmodule Metgauge.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Metgauge.Repo,
      # Start the Telemetry supervisor
      MetgaugeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Metgauge.PubSub},
      # Start the Endpoint (http/https)
      MetgaugeWeb.Endpoint,
      # API client
      {Finch, name: Swoosh.Finch},
      Metgauge.Presence,
      {ConCache, [name: :translate_cache, ttl_check_interval: false]},
      # Start a worker by calling: Metgauge.Worker.start_link(arg)
      # {Metgauge.Worker, arg}
      Metgauge.MQTTClient
    ] ++ cron_jobs()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Metgauge.Supervisor]
    :ets.new(:session, [:named_table, :public, read_concurrency: true])
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MetgaugeWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def application do
    [applications: [:con_cache, :pdf_generator, :html_to_image]]
  end
  

  def cron_jobs do
    []
  end
end