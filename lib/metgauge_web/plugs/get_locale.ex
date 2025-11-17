defmodule MetgaugeWeb.Plugs.GetLocale do
  require Logger

  import Plug.Conn

  @cookie "_mover_app_locale"
  @max_age 60 * 60 * 24 * 3600
  @remember_me_options [sign: false, max_age: @max_age, same_site: "Lax"]

  def init(opts), do: opts

  def call(%{ query_params: %{ "lang" => locale }}=conn, _opts) do
    IO.inspect("1")
    if known_locale?(locale) do
      conn
      |> put_resp_cookie(@cookie, locale, @remember_me_options)
      |> put_request_locale(locale)
    else
      conn
    end
  end

  def call(%{ req_cookies: %{ @cookie => locale }}=conn, _opts) do
    IO.inspect("2")
    if known_locale?(locale) do
      conn 
      |> put_request_locale(locale)
      |> put_resp_cookie(@cookie, locale, @remember_me_options)
    else
      conn
    end
  end

  # Todo: Accept-Language support

  def call(conn, _opts) do
    IO.inspect("3")
    conn = fetch_cookies(conn, signed: [@cookie])
    conn = conn |> delete_resp_cookie(@cookie)
    if Enum.member?(Map.keys(conn.cookies), @cookie) do
      conn
      |> put_request_locale(conn.cookies[@cookie])
      |> put_resp_cookie(@cookie, conn.cookies[@cookie], @remember_me_options)
    else
      if !is_nil(conn.assigns.profile) and conn.assigns.profile.language != nil do
        IO.inspect(conn.assigns.profile.language)
        locale = 
          case conn.assigns.profile.language do
            "Japanese" -> "ja"
            "Chinese" -> "zh_TW"
            _ -> "en"
          end
        conn
        |> put_request_locale(locale)
        |> put_resp_cookie(@cookie, locale, @remember_me_options)
      else
        conn
        |> put_request_locale("en")
        |> put_resp_cookie(@cookie, "en", @remember_me_options)
      end
    end
  end


  def known_locale?(locale) do
    Gettext.known_locales(MetgaugeWeb.Gettext)
    |> Enum.member?(locale)
  end

  def put_request_locale(conn, locale) do
    Gettext.put_locale(MetgaugeWeb.Gettext, locale)
    conn |> assign(:locale, locale)
  end

  def get_cookie(), do: @cookie
end
