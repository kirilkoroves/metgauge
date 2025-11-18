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
  def deliver_confirmation_instructions(conn, user, sent_user, status) do
    text = 
      case status do
        :admin ->
          """
          ==============================

          #{gettext("The user %{first_name} %{last_name} (%{email}) has registered on MetGauge.", first_name: user.profile.first_name, last_name: user.profile.last_name, email: user.email)},

          #{gettext("As administrator for the client %{name} please confirm the user and check their role.", name: user.client.name)}

          #{gettext("If you experience any issues, reach out to us at support@metgauge.com.")}

          #{gettext("Best, The MetGauge team")}

          ==============================
        """
        :superadmin ->
          """
          ==============================

          #{gettext("The user %{first_name} %{last_name} (%{email}) has registered on MetGauge.", first_name: user.profile.first_name, last_name: user.profile.last_name, email: user.email)},

          #{gettext("Because the client %{name} does not have an assigned administrator, please confirm the user and check their role.", name: user.client.name)}

          #{gettext("If you experience any issues, reach out to us at support@metgauge.com.")}

          #{gettext("Best, The MetGauge team")}

          ==============================
          """
      end
    send_confirm_account(text, user, sent_user, status, conn)
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

    #{gettext("We are thrilled to have you join MetGauge !")}

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

  def send_confirm_account(body, user, sent_user, status, conn) do
    new()
    |> from({"MetGauge", @support_email})
    |> to(sent_user.email)
    |> subject(gettext("Action required: Confirm registration on MetGauge"))
    |>
    text_body(body)
    |> render_body("confirm_account.html", %{user: user, status: status, conn: conn})
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
