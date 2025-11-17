defmodule Metgauge.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Metgauge.Accounts.{UserNotification}

  schema "profiles" do
    belongs_to :user, Metgauge.Accounts.User
    field :role, :string, default: "manager"
    field :handle, :string, default: ""
    field :first_name, :string, default: ""
    field :last_name, :string, default: ""
    field :about, :string, default: ""
    field :timezone, :string, default: ""
    field :languages, {:array, :string}, default: []
    field :avatar_path, :string
    field :original_avatar_path, :string
    field :cover_path, :string

    has_many :unanswered_user_notifications, UserNotification, foreign_key: :id
    has_many :answered_user_notifications, UserNotification, foreign_key: :id
  end

  def edit_changeset(profile, attrs, _opts \\ []) do
    profile
    |> cast(attrs, [:first_name, :last_name, :avatar_path, :handle, :cover_path, :about, :timezone, :languages, :original_avatar_path, :avatar_path, :cover_path])
    |> validate_required([:first_name, :last_name])
  end

  def add_changeset(profile, attrs, _opts \\ []) do
    profile
    |> cast(attrs, [:first_name, :last_name, :avatar_path, :handle, :cover_path, :about, :timezone, :languages, :original_avatar_path, :avatar_path, :cover_path, :role])
    |> validate_required([:first_name, :last_name])
  end

  def update_changeset(profile, attrs) do
    profile
    |> cast(attrs, [:first_name, :last_name, :avatar_path, :handle, :cover_path, :about, :timezone, :languages, :original_avatar_path, :avatar_path, :cover_path, :role])
    |> validate_required([:first_name, :last_name, :timezone])
    |> validate_length(:about, max: 2600)
    |> validate_inclusion(:role, ["manager", "operator", "admin", "superadmin"])
  end

  def all_languages(), do: (["English", "Spanish", "Chinese", "Japanese"] ++ (Enum.sort(LanguageList.common_languages) -- ["English", "Spanish", "Chinese", "Japanese"]))
  def languages(), do: (["English", "Spanish", "Chinese", "Japanese"] ++ (Enum.sort(LanguageList.common_languages) -- ["English", "Spanish", "Chinese", "Japanese"])) |> Enum.map(&(%{key: &1, value: Gettext.dgettext(MetgaugeWeb.Gettext, "default", &1)}))
end
