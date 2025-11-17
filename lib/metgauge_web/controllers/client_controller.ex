defmodule MetgaugeWeb.ClientController do
  use MetgaugeWeb, :controller
  alias Metgauge.Accounts.{Client}
  alias Metgauge.Helpers.ChangesetHelpers
  alias Metgauge.Repo

  import Ecto.Query
  @page_size 25

  def index(conn, params) do
    page = Map.get(params, "page", 1)
    query = 
      if Map.get(params, "search_term") != nil do
        from mi in Client, where: is_nil(mi.deleted_at), where: ilike(mi.name, ^"%#{Map.get(params, "search_term")}%"), order_by: mi.name
      else
        from mi in Client, where: is_nil(mi.deleted_at), order_by: mi.name
      end
    render conn, "index.html", page: Repo.paginate(query, page: page, page_size: @page_size), search_term: Map.get(params, "search_term", "")
  end

  def new(conn, _params) do
    changeset = Client.changeset(%Client{}, %{})
    render conn, "new.html", changeset: changeset, form_url: Routes.admin_client_path(conn, :create), client: nil
  end

  def create(conn, %{"client" => params}) do
    with \
      {:ok, %{client: _client}} <- create_client(params)
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

  def edit(conn, %{"id" => id} = _params) do
    case Repo.one(from mi in Client, where: mi.id == ^id and is_nil(mi.deleted_at)) do
      nil -> conn |> redirect(to: Routes.admin_client_path(conn, :index))
      client ->
        changeset = Client.changeset(client, %{})
        render conn, "edit.html", client: client, changeset: changeset, form_url: Routes.admin_client_path(conn, :update, id)
    end
  end

  def delete(conn, %{"id" => id} = _params) do
    case Repo.one(from mi in Client, where: mi.id == ^id and is_nil(mi.deleted_at)) do
      nil -> 
        json conn, %{status: false, message: "Can not delete move item."}
      client ->
        changeset = Client.changeset(client, %{deleted_at: Timex.now()})
        case Repo.update(changeset) do
          {:ok, _} ->
            json conn, %{success: true}
          {:error, _} ->
            json conn, %{success: false, message: "Can not delete move item."}
        end
    end
  end

  def update(conn, %{"id" => id, "client" => params}) do
    client = Repo.one(from mi in Client, where: mi.id == ^id)
    with \
        {:ok, %{client: _client}} <- update_client(client, params)
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

  def create_client(params) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:logo_path, fn _repo, _changes ->
      case params do
        %{"remove_image" => _} ->
          {:ok, nil}
        %{"logo_path" => %{path: path, filename: filename}} ->
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
        _ -> {:ok, nil}
      end
    end)
    |> Ecto.Multi.run(:client, fn _repo, %{logo_path: logo_path} ->
        params = Map.merge(params, %{"logo" => logo_path})
        changeset = Client.changeset(%Client{}, params)
        Repo.insert(changeset)
      end)
    |> Repo.transaction(timeout: :infinity)
  end

  def update_client(client, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:logo_path, fn _repo, _changes ->
      case params do
        %{"remove_image" => _} ->
          {:ok, nil}
        %{"logo_path" => %{path: path, filename: filename}} ->
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
        _ -> {:ok, client.logo}
      end
    end)
    |> Ecto.Multi.run(:client, fn _repo, %{logo_path: logo_path} ->
        params = Map.merge(params, %{"logo" => logo_path})
        changeset = Client.changeset(client, params)
        Repo.update(changeset)
      end)
    |> Repo.transaction(timeout: :infinity)
  end
end