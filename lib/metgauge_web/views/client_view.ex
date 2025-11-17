defmodule MetgaugeWeb.ClientView do
  use MetgaugeWeb, :view

  def logo_image_url(conn, changeset) do
    if Ecto.Changeset.get_field(changeset, :logo) == "" or Ecto.Changeset.get_field(changeset, :logo) == nil do
      Routes.static_path(conn, "/assets/images/placeholder-image.png")
    else
      "/uploads/" <> (Ecto.Changeset.get_field(changeset, :logo))
    end
  end
end
