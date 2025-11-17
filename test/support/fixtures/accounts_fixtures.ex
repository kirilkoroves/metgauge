defmodule Metgauge.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Metgauge.Accounts` context.
  """

  alias Metgauge.{Accounts, Profiles}

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def valid_user_password do
    [Enum.random(?A..?Z),
     (for _ <- 1..5, do: Enum.random(?a..?z)),
     (for _ <- 1..6, do: Enum.random(?0..?9)),
    ] |> IO.iodata_to_binary
  end

  def valid_name(prefix), do: "#{prefix} #{System.unique_integer()}"

  def invalid_user_password, do: "hello world"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      first_name: valid_name("First"),
      last_name: valid_name("Last")
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()
    Profiles.set_onboarded(Accounts.load_profile(user))
    user
  end

  def user_password_fixture(attrs \\ %{}) do
    password = valid_user_password()
    user = user_fixture(Map.put(attrs, :password, password))
    {user, password}
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
