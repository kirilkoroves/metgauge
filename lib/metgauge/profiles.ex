defmodule Metgauge.Profiles do
  require Logger

  import Ecto.Query, warn: false

  alias Metgauge.Repo

  alias Metgauge.Accounts.{Profile, User}
  import MetgaugeWeb.Gettext

  def get_profile_by_handle(handle) when is_binary(handle) do
    Repo.get_by(Profile, handle: handle) |> Repo.preload([:user])
  end

  def add_profile(attrs) do
    %Profile{}
    |> Profile.add_changeset(attrs)
    |> Repo.insert()
  end

  def update(%Profile{} = profile, attrs \\ %{}) do
    Profile.update_changeset(profile, attrs)
    |> Repo.update()
  end

  def summary_map(nil), do: nil
  def summary_map(profile), do: profile

  def update_profile(profile, params) do
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
        interests = Map.get(params, "interests", [])
        params = Map.merge(params, %{"avatar_path" => avatar_path, "interests" => interests})
        changeset = Profile.update_changeset(profile, params)
        Repo.update(changeset)
      end)
    |> Ecto.Multi.run(:user, fn _repo, %{} ->
      user = Repo.get(User, profile.user_id)
      User.update_email_changeset(user, %{"email" => params["email"]})
      |> Repo.update()
    end)
    |> Repo.transaction(timeout: :infinity)
  end
end
