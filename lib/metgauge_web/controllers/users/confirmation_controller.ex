defmodule MetgaugeWeb.Users.ConfirmationController do
  use MetgaugeWeb, :controller

  alias Metgauge.Accounts
  alias Metgauge.Accounts.UserNotifier
  alias MetgaugeWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def resend_confirmation(conn, _params) do
      Accounts.deliver_user_confirmation_instructions(
        conn,
        conn.assigns.current_user,
        &Routes.user_confirmation_url(conn, :edit, &1)
      )
    conn
    |> put_flash(
      :info,
      gettext(
        "Please check your email for the confirmation"
      )
    )
    |> redirect(to: "/")
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(conn,
        user,
        &Routes.user_confirmation_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      gettext(
        "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."
      )
    )
    |> redirect(to: "/")
  end

  def edit(conn, %{"token" => token}) do
    #render(conn, "edit.html", token: token)
    update(conn, %{"token" => token})
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def update(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, user} ->
        UserNotifier.deliver_welcome_email(conn, user)
        user = Metgauge.Repo.preload(user, :profile)
        conn
        |> UserAuth.log_in_user(user)
        |> put_flash(:info, gettext("User confirmed successfully."))
        |> halt()

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
            |> put_flash(:error, gettext("User confirmation link is invalid or it has expired."))
            |> redirect(to: "/")
            |> halt()
        end
    end
  end

  def halt(conn, _) do
    render(conn, "halt.html")
  end
end
