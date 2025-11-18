defmodule MetgaugeWeb.UserView do
  use MetgaugeWeb, :view

  def get_role_string("superadmin"), do: "Super Admin"
  def get_role_string("admin"), do: "Admin"
  def get_role_string("operator"), do: "Operator"
  def get_role_string("manager"), do: "Manager"
end
