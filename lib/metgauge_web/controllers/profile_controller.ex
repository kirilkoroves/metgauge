defmodule MetgaugeWeb.ProfileController do
  use MetgaugeWeb, :controller
  alias Metgauge.Accounts.Profile
  alias Metgauge.Profiles
  alias Metgauge.Helpers.ChangesetHelpers

  def edit(conn, _params) do
    profile = conn.assigns.profile
    attrs = %{email: conn.assigns.current_user.email}
    changeset = Profile.edit_changeset(profile, attrs)
    render(conn, "edit.html", profile: profile, changeset: changeset)
  end

  def update(conn, %{"profile" => params} = _attrs) do
    profile = conn.assigns.profile
    IO.inspect(params)
    with \
      {:ok, %{profile: _profile}} <- Profiles.update_profile(profile, params)
    do
      json(conn, %{status: "OK"})
    else
      {:error, _model, %{field: field} = _error_field, _data} ->
        json(conn, %{status: "ERROR", fields: [%{field: field, message: gettext("Invalid input")}]})
      {:error, model, message, _data} when is_binary(message) ->
        json(conn, %{status: "ERROR", fields: [%{field: model, message: message}]})
      {:error, _model, changeset, _data} ->
        IO.inspect(changeset);
        json(conn, %{status: "ERROR", fields: ChangesetHelpers.changeset_error_to_array(changeset)})
    end
  end
end
