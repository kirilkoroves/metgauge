defmodule Metgauge.Accounts.UserNotifier do
  import Swoosh.Email
  import MetgaugeWeb.Gettext
  use Phoenix.Swoosh, view: MetgaugeWeb.UserNotifierView, layout: {MetgaugeWeb.LayoutView, :email}

  alias Metgauge.Mailer
  import MetgaugeWeb.Gettext

  @support_email "support@metgauge.com"

  defp deliver_html(email) do
    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end


  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(conn, user, url) do
    user = Metgauge.Repo.preload(user, :profile)
    send_confirm_account("""

    ==============================

    #{gettext("Hi %{first_name}", first_name: user.profile.first_name)},

    #{gettext("Thank you for signing up Commercial Works App !")}

    #{gettext("We'd like to confirm that your account was created successfully. To complete the registration click the link below.")}

    <a href="#{url}">#{gettext("Complete the registration")}</a>

    #{gettext("If you experience any issues signing into your account, reach out to us at support@metgauge.com.")}

    #{gettext("Best, The Commercial Works App team")}

    ==============================
    """, user, url, conn)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(conn, user, url) do
    user = Metgauge.Repo.preload(user, :profile)
    send_reset_instructions("""
    ==============================

    #{gettext("Hi %{first_name}", first_name: user.profile.first_name)},

    #{gettext("You can reset your password by visiting the URL below:")}

    #{url}

    #{gettext("If you didn't request this change, please ignore this.")}

    ==============================
    """, user, url, conn)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(conn, user, url) do
    user = Metgauge.Repo.preload(user, :profile)
    send_update_email_instructions("""

    ==============================

    #{gettext("Hi %{first_name}", first_name: user.profile.first_name)},

    #{gettext("You can change your email by visiting the URL below:")}

    #{url}

    #{gettext("If you didn't request this change, please ignore this.")}

    ==============================
    """, user, url, conn)
  end

  def deliver_welcome_email(conn, user) do
    user = Metgauge.Repo.preload(user, :profile)
    profile = user.profile
    IO.inspect profile
    send_welcome_email("""

    ==============================

    #{gettext("Hi %{first_name}", first_name: profile.first_name)},

    #{gettext("We are thrilled to have you join metgauge !")}

    #{gettext("Account ID:")} #{user.email}

    #{gettext("Can't wait to see your service offering on MetGauge and grow with us!  Contact us at (support@metgauge.com) if there is any feedback or question. A huge thank you to be part of us!")}

    #{gettext("Best, The MetGauge team")}

    ==============================
    """, user, conn)
  end

  def send_welcome_email(body, user, conn) do
    new()
    |> from({"MetGauge", "support@metgauge.com"})
    |> to(user.email)
    |> subject(gettext("Welcome to MetGauge !"))
    |> text_body(body)
    |> render_body("welcome_email.html", %{profile: user.profile, user: user, conn: conn})
    |> deliver_html()
  end

  def send_update_email_instructions(body, user, url, conn) do
    new()
    |> from({"MetGauge", @support_email})
    |> to(user.email)
    |> subject(gettext("Update your email %{user_email}", user_email: user.email))
    |> text_body(body)
    |> render_body("update_email.html", %{user: user, url: url, conn: conn})
    |> deliver_html()
  end

  def send_reset_instructions(body, user, url, conn) do
    new()
    |> from({"MetGauge", @support_email})
    |> to(user.email)
    |> subject(gettext("Reset your account %{user_email}", user_email: user.email))
    |> text_body(body)
    |> render_body("password_reset.html", %{user: user, url: url, conn: conn})
    |> deliver_html()
  end

  def send_confirm_account(body, user, url, conn) do
    new()
    |> from({"MetGauge", @support_email})
    |> to(user.email)
    |> subject(gettext("Action required: Confirm registration on MetGauge"))
    |>
    text_body(body)
    |> render_body("confirm_account.html", %{user: user, url: url, conn: conn})
    |> deliver_html()
  end

  def send_body_email(email, body, subject) do
    new()
    |> from({"MetGauge", @support_email})
    |> to(email)
    |> subject(subject)
    |> text_body(body)
    |> deliver_html()
  end

  def atomize_map(map) do
    Enum.map(map, fn {key, value} ->
      {String.to_atom(key), value}
    end)
    |> Map.new()
  end
end
