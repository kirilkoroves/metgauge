defmodule MetgaugeWeb.ProfileView do
  use MetgaugeWeb, :view
  import MetgaugeWeb.Helpers.{OptionHelpers}
  alias Metgauge.Accounts.Profile
  alias Metgauge.Helpers.AzureHelpers

  def languages() do
    Profile.languages()
    |> Enum.map(fn(l)-> %{key: l, value: l} end)
  end
  
  def profile_cover_photo(conn, profile) do
    if profile.cover_path == "" or profile.cover_path == nil do
      "background: url('#{Routes.static_path(conn, "/assets/images/default_banner_image.png")}')"
    else
      "background: url('#{Routes.static_path(conn, "/uploads/"<>profile.cover_path)}'); background-position: #{profile.cover_position};"
    end
  end

  def profile_image_url(conn, profile) do
    if profile == nil or profile.avatar_path == "" or profile.avatar_path == nil do
      Routes.static_url(conn, "/assets/svg/generic/no_profile_photo.svg")
    else
      Routes.static_path(conn, "/uploads/#{profile.avatar_path}")
    end
  end

  def profile_email_image_url(conn, profile) do
    if profile == nil or profile.avatar_path == "" or profile.avatar_path == nil do
      Routes.static_url(conn, "/assets/images/no_profile.png")
    else
      Routes.static_url(conn, "/uploads/#{profile.avatar_path}")
    end
  end

end
