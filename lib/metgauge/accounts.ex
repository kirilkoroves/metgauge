defmodule Metgauge.Accounts do
  @moduledoc """
  The Accounts context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias Metgauge.Repo
  alias Metgauge.Accounts.{UserNotification}

  alias Metgauge.Accounts.{User, UserToken, UserNotifier}

  ## Database getters

  def get_user_by_email(email) when is_binary(email) do
     Repo.get_by(User, email: email) |> Repo.preload(:profile)
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: Repo.preload(user, :profile)
  end

  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  def register_user(attrs) do
    # We get strings from the web, but atoms from tests.
    # This is the least awful way I could find to avoid mixing them.
    profile_key =
      case Map.keys(attrs) do
        [k | _] when is_binary(k) -> "profile"
        _ -> :profile
      end

    %User{}
    |> User.registration_changeset(Map.put(attrs, profile_key, attrs))
    |> Repo.insert()
  end

  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  ## Settings

  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs)
  end

  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  def deliver_update_email_instructions(conn, %User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(conn, user, update_email_url_fun.(encoded_token))
  end

  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  def deliver_user_confirmation_instructions(conn, %User{} = user, %User{} = sent_user, status) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      UserNotifier.deliver_confirmation_instructions(conn, user, sent_user, status)
    end
  end

  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  def deliver_user_reset_password_instructions(conn, %User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(conn, user, reset_password_url_fun.(encoded_token))
  end

  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def fetch_or_create_user(attrs) do
    case get_user_by_email(attrs.email) do
      %User{} = user ->
        {:ok, user}

      _ ->
        %User{}
        |> User.registration_changeset(attrs)
        |> Repo.insert()
    end
  end

  def load_profile(nil), do: nil

  def load_profile(user) do
    profile = Repo.one!(Ecto.assoc(user, :profile))
    unanswered_user_notifications = Repo.all(from u in UserNotification, where: u.is_answered == ^false and u.profile_id == ^profile.id, order_by: [desc: u.inserted_at], limit: 3)
    profile |> Map.merge(%{unanswered_user_notifications: unanswered_user_notifications})
  end
end