defmodule MetgaugeWeb.Users.OauthController do
  use MetgaugeWeb, :controller

  alias Metgauge.{Accounts, Accounts.User, Accounts.Profile}
  alias MetgaugeWeb.UserAuth
  alias Metgauge.Repo

  plug Ueberauth
  @rand_pass_length 32
  @cookie "_metgauge_affiliate"

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    auth.info.email
    |> Accounts.get_user_by_email()
    |> sign_in_or_sign_up(conn, auth)
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn = conn |> delete_resp_cookie(@cookie)
    conn
    |> put_flash(:error,  gettext("Failed to authenticate."))
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp sign_in_or_sign_up(%User{confirmed_at: nil}, conn, _auth),
    do: redirect(conn, to: "/auth/halt")

  defp sign_in_or_sign_up(%User{} = user, conn, _auth),
    do: user_sign_in({:ok, user}, conn)

  defp sign_in_or_sign_up(_, conn, auth) do
    %Ueberauth.Auth{
      info: %Ueberauth.Auth.Info{
        name: username,
        email: email,
        first_name: first_name,
        last_name: last_name
      },
      provider: provider
    } = auth

    IO.inspect(conn.assigns[:affiliate_code])
    affiliate_id = 
      if conn.assigns[:affiliate_code] != nil do
        profile = Repo.get_by(Profile, slug: conn.assigns[:affiliate_code])
        if profile != nil do
          profile.id
        else
          nil
        end
      else
          nil
      end

    params = %{name: username, email: email, first_name: first_name, last_name: last_name, provider: Atom.to_string(provider), password: random_password(), affiliate_id: affiliate_id}

    conn = conn |> delete_resp_cookie(@cookie)
    
    with \
      {:ok, user} <- Accounts.register_user(params),
      {:ok, _} <- send_confirmation(user, conn)
    do
      user_hold_confirmation({:ok,user}, conn)
    else
      error ->
        user_hold_confirmation(error, conn)
    end
  end

  defp send_confirmation({:error, %Ecto.Changeset{}} = reason, _conn),
    do: {:error, reason}

  defp send_confirmation(user, conn) do
    Accounts.deliver_user_confirmation_instructions(conn,
      user,
      &Routes.user_confirmation_url(conn, :edit, &1),
      ""
    )
  end

  defp user_sign_in({:ok, user}, conn) do
    conn
    |> delete_resp_cookie(@cookie)
    |> UserAuth.log_in_user(user)
  end

  defp user_hold_confirmation({:ok, _user}, conn), do: redirect(conn, to: "/auth/halt")

  defp user_hold_confirmation({:error, reason}, conn) do
    conn
    |> put_flash(
      :error,
      gettext("Oops, something went wrong! Please check the errors below.")
    )
    |> put_flash(:error, reason)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp random_password do
    :crypto.strong_rand_bytes(@rand_pass_length) |> Base.encode64()
  end
end
