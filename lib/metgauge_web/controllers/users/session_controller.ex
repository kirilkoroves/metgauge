defmodule MetgaugeWeb.Users.SessionController do
  require Logger

  use MetgaugeWeb, :controller

  alias Metgauge.Accounts
  alias Metgauge.Accounts.Profile
  alias Metgauge.Repo
  alias MetgaugeWeb.UserAuth
  import Plug.Conn

  def new(conn, params) do
    conn = case Map.get(params, "return") do
      nil -> conn
      path -> put_session(conn, :user_return_to, path)
    end

    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, gettext "Invalid email or password")
      |> render("new.html", error_message: gettext "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, gettext "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  def sudo_login(conn, %{"profile_handle" => profile_handle} = _params) do
    if conn.assigns.profile != nil and (conn.assigns.profile.handle == "kiril") do
      profile = Repo.get_by(Profile, handle: profile_handle) |> Repo.preload(:user)
      user = profile.user |> Map.put(:profile, profile)
      conn
      |> UserAuth.log_in_user(user)
    else
      conn
      |> redirect(to: "/admin")
    end
  end
end
