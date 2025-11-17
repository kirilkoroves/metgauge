defmodule MetgaugeWeb.Plugs.AdminAccess do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    user = conn.assigns[:current_user]
    profile = conn.assigns[:profile]
    if profile == nil or (profile.role in ["superadmin", "admin", "operator", "manager"] and user.deactivated_at == nil) do
      conn
    else
      conn
      |> Phoenix.Controller.put_root_layout({MetgaugeWeb.LayoutView, :landing})
      |> Phoenix.Controller.render(MetgaugeWeb.AdminView, "forbidden.html")
      |> halt()
    end
  end
end
