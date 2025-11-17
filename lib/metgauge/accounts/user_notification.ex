defmodule Metgauge.Accounts.UserNotification do
  require Logger

  use Ecto.Schema
  import Ecto.Changeset

  schema "user_notifications" do
    field :type, :string, default: "notification"
    field :content, :string
    field :is_answered, :boolean
    field :link, :string
    belongs_to :profile, Metgauge.Accounts.Profile

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:type, :content, :is_answered, :link, :profile_id])
    |> validate_required([:profile_id, :type])
  end
end