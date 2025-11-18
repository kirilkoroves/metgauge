defmodule MetgaugeWeb.AdminController do
  use MetgaugeWeb, :controller
  import Ecto.Query
  alias Metgauge.{Accounts.Client, Accounts.User}
  alias Metgauge.Repo
  alias Metgauge.Accounts.UserNotification
  import Phoenix.LiveView.Controller

  def index(%{assigns: %{profile: %{role: role}}} = conn, _params) when role in ["superadmin", "admin"] do
    today_str = Timex.now() |> Timex.format!("%m/%d/%Y", :strftime)
    today = Timex.now() |> Timex.to_date()
    render conn, "index.html", report_data: report_data(conn, today, today), from: today_str, to: today_str
  end

  def index(conn, _params) do
    live_render(conn, MetgaugeWeb.DashboardLive.Index,
      session: %{"user" => Repo.preload(conn.assigns.current_user, :client), "profile" => conn.assigns.profile},
      router: MetgaugeWeb.Router
    )
  end

  def report_data(conn, start_date, end_date) do
    clients = 
      if conn.assigns.profile.role == "superadmin" do
        Repo.one(from c in Client, where: is_nil(c.deleted_at) and fragment("CAST(inserted_at AS DATE) BETWEEN ? AND ?", ^start_date, ^end_date), select: count(c.id))
      else
        Repo.one(from c in Client, where: is_nil(c.deleted_at) and c.id == ^conn.assigns.current_user.client_id and fragment("CAST(inserted_at AS DATE) BETWEEN ? AND ?", ^start_date, ^end_date), select: count(c.id))
      end

    users = 
      if conn.assigns.profile.role == "superadmin" do
        Repo.all(from u in User, where: is_nil(u.deactivated_at) and not is_nil(u.client_id) and fragment("CAST(inserted_at AS DATE) BETWEEN ? AND ?", ^start_date, ^end_date), preload: :client)
      else
        Repo.all(from u in User, where: is_nil(u.deactivated_at) and not is_nil(u.client_id) and u.client_id == ^conn.assigns.current_user.client_id and fragment("CAST(inserted_at AS DATE) BETWEEN ? AND ?", ^start_date, ^end_date), preload: :client)
      end

    
    count_by_clients = 
      Enum.group_by(users, (&(&1.client_id)))
      |> Enum.map(fn {_client_id, users} ->
        %{name: Enum.at(users, 0).client.name, count: Enum.count(users)}
      end)
      |> Enum.sort_by(&(&1.count), :desc)

    %{new_clients: clients, total_users: Enum.count(users), count_by_clients: count_by_clients}
  end

  def report_widget(conn, %{"from" => from_date, "to" => to_date}) do
    start_date = Timex.parse!(from_date, "%m/%d/%Y", :strftime) |> Timex.to_date()
    end_date = Timex.parse!(to_date, "%m/%d/%Y", :strftime) |> Timex.to_date()
    report_data = report_data(conn, start_date, end_date)
    conn
    |> put_root_layout(false)
    |> render("_report_widget.html", conn: conn, report_data: report_data)
  end

  def user_notifications(conn, _params) do
    user_notifications =
      Repo.all(from u in Metgauge.Accounts.UserNotification,
      where: u.profile_id == ^conn.assigns.profile.id,
      # order_by: [u.is_answered,
      # desc: u.inserted_at],
      order_by: [desc: u.inserted_at],
      limit: 10) |> Repo.preload([:notification_from_profile])

      grouped_notifications =
      user_notifications
      |> Enum.group_by(fn(notification) ->
        MetgaugeWeb.AdminView.format_user_notification_datetime(conn, notification.inserted_at)
      end)
      |> Enum.sort_by(fn {_key, value} -> hd(value).inserted_at end, {:desc, Date})

    # query = from u in UserNotification, where: u.profile_id == ^conn.assigns.profile.id
    # Repo.update_all(query, set: [is_answered: true])

    ids = Enum.map(user_notifications, &(&1.id))
      query = from u in UserNotification, where: u.id in ^ids
      Repo.update_all(query, set: [is_answered: true])

    render(conn, "user_notifications.html",
      user_notifications: grouped_notifications
    )
  end

  def user_notifications_lazy(conn, params) do
    offset = params["offset"]
    limit = params["limit"]
    IO.inspect limit
    IO.inspect offset
    user_notifications =
      Repo.all(from u in Metgauge.Accounts.UserNotification,
      where: u.profile_id == ^conn.assigns.profile.id,
      # order_by: [u.is_answered,
      # desc: u.inserted_at],
      order_by: [desc: u.inserted_at],
      limit: ^limit, offset: ^offset)

    grouped_notifications =
      user_notifications
      |> Enum.group_by(fn(notification) ->
        MetgaugeWeb.AdminView.format_user_notification_datetime(conn, notification.inserted_at)
      end)
      |> Enum.sort_by(fn {_key, value} -> hd(value).inserted_at end, {:desc, Date})

    # query = from u in UserNotification, where: u.profile_id == ^conn.assigns.profile.id
    # Repo.update_all(query, set: [is_answered: true])

    ids = Enum.map(user_notifications, &(&1.id))
      query = from u in UserNotification, where: u.id in ^ids
      Repo.update_all(query, set: [is_answered: true])

    if(Enum.count(grouped_notifications) > 0) do
      conn
      |> put_layout(false)
      |> put_root_layout(false)
      |> render(MetgaugeWeb.AdminView,
      "_user_notifications_lazy.html",
      user_notifications: grouped_notifications
      )
    else
      json(conn, %{reachedEnd: true})
    end

  end
end
