defmodule MetgaugeWeb.Users.SettingsController do
  use MetgaugeWeb, :controller

  alias Metgauge.Accounts
  alias Metgauge.Accounts.UserNotification
  alias MetgaugeWeb.UserAuth
  alias Metgauge.Repo

  import Ecto.Query

  plug :assign_email_and_password_changesets when action not in [:get_notifications, :get_notifications_lazy]

  def get_notifications(conn, _params) do
    if is_nil(conn.assigns.profile) do
      notifications = []
      conn
      |> put_layout(false)
      |> render(MetgaugeWeb.LayoutView, "_user_notifications.html", user_notifications: notifications)
    else
      # unanswered_user_notifications = Repo.all(from u in UserNotification, where: u.is_answered == ^false and u.profile_id == ^conn.assigns.profile.id, order_by: [desc: u.inserted_at], limit: 10)
      # limit = 10 - Enum.count(unanswered_user_notifications)
      # answered_user_notifications = Repo.all(from u in UserNotification, where: u.is_answered == ^true and u.profile_id == ^conn.assigns.profile.id, order_by: [desc: u.inserted_at], limit: ^limit)

      notifications = Repo.all(
        from u in UserNotification,
        where: u.profile_id == ^conn.assigns.profile.id,
        order_by: [desc: u.inserted_at], limit: 10
      ) |> Repo.preload([:notification_from_profile, :booking])

      ids = Enum.map(notifications, &(&1.id))
      query = from u in UserNotification, where: u.id in ^ids
      Repo.update_all(query, set: [is_answered: true])

      # notifications = unanswered_user_notifications ++ answered_user_notifications
      conn
      |> put_layout(false)
      |> put_root_layout(false)
      |> render(MetgaugeWeb.LayoutView, "_user_notifications.html", user_notifications: notifications, conn: conn)
    end
  end

  def get_notifications_lazy(conn, params) do
    offset = params["offset"]
    limit = params["limit"]
    if is_nil(conn.assigns.profile) do
      notifications = []
      if(Enum.count(notifications) > 0) do
        conn
      |> put_layout(false)
      |> render(MetgaugeWeb.LayoutView, "_user_notifications.html", user_notifications: notifications)
      else
        json(conn, %{reachedEnd: true})
      end
    else
      # unanswered_user_notifications = Repo.all(from u in UserNotification, where: u.is_answered == ^false and u.profile_id == ^conn.assigns.profile.id, order_by: [desc: u.inserted_at], limit: 3)
      # limit = 3 - Enum.count(unanswered_user_notifications)
      # answered_user_notifications = Repo.all(from u in UserNotification, where: u.is_answered == ^true and u.profile_id == ^conn.assigns.profile.id, order_by: [desc: u.inserted_at], limit: ^limit)

      notifications = Repo.all(
        from u in UserNotification,
        where: u.profile_id == ^conn.assigns.profile.id,
        order_by: [desc: u.inserted_at], limit: ^limit, offset: ^offset
      ) |> Repo.preload([:notification_from_profile, :booking])

      ids = Enum.map(notifications, &(&1.id))
      query = from u in UserNotification, where: u.id in ^ids
      Repo.update_all(query, set: [is_answered: true])

      #notifications = unanswered_user_notifications ++ answered_user_notifications

      if(Enum.count(notifications) > 0) do
        conn
      |> put_layout(false)
      |> put_root_layout(false)
      |> render(MetgaugeWeb.LayoutView, "_user_notifications.html", user_notifications: notifications)
      else
        json(conn, %{reachedEnd: true})
      end
    end
  end

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(conn,
          applied_user,
          user.email,
          &Routes.user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          gettext("A link to confirm your email change has been sent to the new address.")
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info,  gettext("Password updated successfully."))
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, gettext("Email changed successfully."))
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, gettext("Email change link is invalid or it has expired."))
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end
end
