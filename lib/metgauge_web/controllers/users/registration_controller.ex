defmodule MetgaugeWeb.Users.RegistrationController do
  require Logger
  use MetgaugeWeb, :controller

  alias Metgauge.{Accounts, Accounts.User, Accounts.Client}
  alias Metgauge.Repo
  import Ecto.Query

  def new(conn, params) do
    changeset = Accounts.change_user_registration(%User{})
    client_id = 
      case Map.get(params, "client_slug") do
        nil -> nil
        slug -> 
          case Repo.get_by(Client, slug: slug) do
            nil -> nil
            client -> client.id
          end
      end

    clients = Repo.all(from c in Client, order_by: c.name, select: {c.name, c.id})
    roles = [{"Operator", "operator"}, {"Manager", "manager"}]
    render(conn, "new.html", changeset: changeset, client_id: client_id, clients: clients, roles: roles)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        user = Repo.preload(user, [:client, :profile])
        {status, sent_user} = 
          if user.client_id != nil do
            case Repo.one(from u in User, join: p in assoc(u, :profile), where: u.client_id == ^user.client_id and p.role == ^"admin", limit: 1) do
              nil -> {:superadmin, Repo.one(from u in User, join: p in assoc(u, :profile), where: p.role == ^"superadmin", limit: 1)}
              user -> {:admin, user}
            end
          else
            {:superadmin, Repo.one(from u in User, join: p in assoc(u, :profile), where: p.role == ^"superadmin", limit: 1)}
          end

          {:ok, _} =
            Accounts.deliver_user_confirmation_instructions(conn,
              user,
              sent_user,
              status
            )

          redirect(conn, to: "/auth/halt")

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        client_id = Ecto.Changeset.get_field(changeset, :client_id)
        clients = Repo.all(from c in Client, order_by: c.name, select: {c.name, c.id})
        roles = [{"Operator", "operator"}, {"Manager", "manager"}]

        conn
        |> put_flash(
          :error,
          gettext("Oops, something went wrong! Please check the errors below.")
        )
        |> render("new.html", changeset: changeset, client_id: client_id, clients: clients, roles: roles)
    end
  end
end
