defmodule MetgaugeWeb.Users.RegistrationController do
  require Logger
  use MetgaugeWeb, :controller

  alias Metgauge.{Accounts, Accounts.User, Accounts.Profile}
  alias Metgauge.Repo

  def new(conn, params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(conn,
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        redirect(conn, to: "/auth/halt")

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        conn
        |> put_flash(
          :error,
          gettext("Oops, something went wrong! Please check the errors below.")
        )
        |> render("new.html", changeset: changeset, affiliate_id: Map.get(user_params, "affiliate_id"))
    end
  end
end
