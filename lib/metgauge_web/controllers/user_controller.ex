defmodule MetgaugeWeb.UserController do
  use MetgaugeWeb, :controller
  alias Metgauge.Accounts.{User, Profile, Client}
  alias Metgauge.Helpers.ChangesetHelpers
  alias Metgauge.Helpers.AzureHelpers
  
  alias Metgauge.Repo

  import Ecto.Query
  @page_size 25

  def index(conn, params) do
    page = Map.get(params, "page", 1)
    status = Map.get(params, "status", "active")
    query = 
      if Map.get(params, "search_term") != nil do
        from p in Profile, join: u in assoc(p, :user), left_join: c in Client, on: c.id == u.client_id, where: ilike(p.first_name, ^"%#{Map.get(params, "search_term")}%") or ilike(p.last_name, ^"%#{Map.get(params, "search_term")}%") or ilike(u.email, ^"%#{Map.get(params, "search_term")}%"), order_by: [desc: u.inserted_at], preload: [user: {u, client: c}]
      else
        from p in Profile, join: u in assoc(p, :user), left_join: c in Client, on: c.id == u.client_id, order_by: [desc: u.inserted_at], preload: [user: {u, client: c}]
      end

    query = 
      if status == "active" do
        from [p, u, c] in query, where: is_nil(u.deactivated_at) 
      else
        from [p, u, c] in query, where: not is_nil(u.deactivated_at)
      end

    render conn, "index.html", page: Repo.paginate(query, page: page, page_size: @page_size), search_term: Map.get(params, "search_term", ""), status: status
  end

  def edit(conn, %{"id" => id} = _params) do
    profile = Repo.one(from p in Profile, join: u in assoc(p, :user), preload: [user: u], where: p.id == ^id)
    case profile do
      nil -> conn |> redirect(to: Routes.admin_user_path(conn, :index))
      profile ->
        clients = Repo.all(from c in Client, order_by: c.name, select: {c.name, c.id})
        attrs = %{email: profile.user.email, client_id: profile.user.client_id}
        IO.inspect(attrs)
        changeset = Profile.edit_changeset(profile, attrs)
        IO.inspect(changeset)
        roles = 
          if conn.assigns.profile.role == "superadmin" do
            [{"Operator", "operator"}, {"Manager", "manager"}, {"Admin", "admin"}, {"Super Admin", "superadmin"}]
          else
            [{"Operator", "operator"}, {"Manager", "manager"}, {"Admin", "admin"}]
          end
        render conn, "edit.html", profile_model: profile, changeset: changeset, clients: [{"None", nil}] ++ clients, form_url: Routes.admin_user_path(conn, :update, id), roles: roles
    end
  end

  def toggle_deactivate(conn, %{"id" => id} = _params) do
    profile = Repo.one(from p in Profile, join: u in assoc(p, :user), preload: [user: u], where: p.id == ^id)
    changeset = User.toggle_deactivated_changeset(profile.user)
    case Repo.update(changeset) do
      {:error, _} -> 
        json conn, %{status: false, message: "Can not change user status."}
      {:ok, _user} ->
        json conn, %{success: true}
    end
  end

  def confirm(conn, %{"id" => id} = _params) do
    profile = Repo.one(from p in Profile, join: u in assoc(p, :user), preload: [user: u], where: p.id == ^id)
    changeset = User.confirm_changeset(profile.user)
    case Repo.update(changeset) do
      {:error, _} -> 
        json conn, %{status: false, message: "Can not confirm user."}
      {:ok, _user} ->
        json conn, %{success: true}
    end
  end

  def filter(conn, params) do
    page = Map.get(params, "page", 1)
    status = Map.get(params, "status", "active")
    query = 
      if Map.get(params, "search_term") != nil do
        from p in Profile, join: u in assoc(p, :user), where: ilike(p.first_name, ^"%#{Map.get(params, "search_term")}%") or ilike(p.last_name, ^"%#{Map.get(params, "search_term")}%") or ilike(u.email, ^"%#{Map.get(params, "search_term")}%"), order_by: [desc: u.inserted_at], preload: [user: u]
      else
        from p in Profile, join: u in assoc(p, :user), order_by: [desc: u.inserted_at], preload: [user: u]
      end

    query = 
      if status == "active" do
        from [p, u] in query, where: is_nil(u.deactivated_at) 
      else
        from [p, u] in query, where: not is_nil(u.deactivated_at)
      end

    conn
    |> put_root_layout(false)
    |> render("_user_list.html", page: Repo.paginate(query, page: page, page_size: @page_size))
  end

  def update(conn, %{"id" => id, "profile" => params}) do
    profile = Repo.one(from p in Profile, where: p.id == ^id, preload: [:user])
    with \
        {:ok, %{user: _user}} <- update_user(profile, params)
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

  def update_user(profile, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:avatar_path, fn _repo, _changes ->
      case params do
        %{"remove_image" => _} ->
          {:ok, nil}
        %{"avatar_path" => %{path: path, filename: filename}} ->
          try do
            Mogrify.open(path) |> Mogrify.resize_to_limit("300x300") |> Mogrify.quality("90") |> Mogrify.save(in_place: true)
            uuid = UUID.uuid4()
            file_extension = Path.extname(filename)
            new_path = File.cwd! <> "/uploads/" <> uuid <> file_extension
            File.rename(path, new_path)
            {:ok, uuid <> file_extension}
          rescue
            error ->
              IO.inspect(error)
              {:error, gettext("Not able to upload image")}
          end
        _ -> {:ok, profile.avatar_path}
      end
    end)
    |> Ecto.Multi.run(:profile, fn _repo, %{avatar_path:  avatar_path} ->
        params = Map.merge(params, %{"avatar_path" => avatar_path})
        changeset = Profile.update_changeset(profile, params)
        Repo.update(changeset)
      end)
    |> Ecto.Multi.run(:user, fn _repo, %{} ->
      user = Repo.get(User, profile.user_id)
      User.update_email_changeset(user, %{"email" => params["email"], "client_id" => params["client_id"]})
      |> Repo.update()
    end)
    |> Ecto.Multi.run(:password, fn _repo, %{user: user} ->
      if Map.get(params, "password", "") != "" do
        User.password_changeset(user, params)
        |> Repo.update()
      else
        {:ok, nil}
      end
    end)
    |> Repo.transaction(timeout: :infinity)
  end
end