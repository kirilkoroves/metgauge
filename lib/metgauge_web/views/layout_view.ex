defmodule MetgaugeWeb.LayoutView do
  require Logger

  alias Plug.Conn

  use MetgaugeWeb, :view

  #alias Metgauge.Profiles

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def locale_link(%Conn{ query_params: params }=conn, locale) do
    query = Conn.Query.encode(Map.merge(params, %{ "lang" => locale, "override" => true }))
    path = Phoenix.Controller.current_path(conn, %{})
    "#{path}?#{query}"
  end

  def html_lang(%{assigns: %{locale: locale}} = _conn) do
    locale
    |> String.replace("_", "-")
  end
  def html_lang(_conn), do: "en"

  def get_endpoint_active_class(conn, path) do
    if conn.request_path == path, do: "active", else: ""
  end
  
  def meta_image_width(_assigns) do
    "400"
  end

  def meta_image_height(_assigns) do
    "400"
  end

  def meta_title(_assigns) do
    "Commercial Works"
  end

  def meta_description(%{conn: %{private: %{:phoenix_template => "hero.html", :phoenix_view => MetgaugeWeb.HeroView}} = conn}) do
    case conn.assigns.hero.about do
      "" -> gettext "Join the global talent pool to trade skills and time"
      about -> about
    end
  end
  def meta_description(_assigns) do
    gettext "Commercial Works provides commercial moving and storage, workplace interors, and logistics services for business nationwide. Contact us to learn more!"
  end

  def meta_type(_assigns) do
    "website"
  end

  def meta_price_tags(_assigns) do
    ""
  end

  def meta_image(%{conn: conn} = _assigns) do
    Routes.static_url(conn, "/assets/images/seo_img.png")
  end
end
