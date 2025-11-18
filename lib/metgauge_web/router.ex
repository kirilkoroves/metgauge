defmodule MetgaugeWeb.Router do
  use MetgaugeWeb, :router

  require Logger

  import MetgaugeWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug MetgaugeWeb.Plugs.GetLocale
  end

  pipeline :app do
    plug :browser
    plug :put_root_layout, {MetgaugeWeb.LayoutView, :landing}
  end

  pipeline :registration do
    plug :app
    plug :put_root_layout, {MetgaugeWeb.LayoutView, :landing}
    plug :put_layout_class, "registration"
  end

  pipeline :landing do
    plug :app
    plug :put_layout_class, "landing"
  end

  pipeline :password_reset do
    plug :app
    plug :put_layout_class, "password-reset"
  end

  pipeline :onboard do
    plug :app
    plug :put_layout_class, "onboard"
  end

  pipeline :admin do
    plug :browser
    plug MetgaugeWeb.Plugs.AdminAccess
    plug :put_root_layout, {MetgaugeWeb.LayoutView, :admin}
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug MetgaugeWeb.Plugs.GetLocale
    plug MetgaugeWeb.Plugs.AdminAccess
  end
  
  scope "/", MetgaugeWeb, as: :user do
    pipe_through [:browser]
    get "/auth/resend_confirmation", Users.ConfirmationController, :resend_confirmation
    get "/auth/confirm/:token", Users.ConfirmationController, :edit
    post "/auth/confirm/:token", Users.ConfirmationController, :update
    get "/get_notifications", Users.SettingsController, :get_notifications
    get "/get_notifications_lazy", Users.SettingsController, :get_notifications_lazy
  end

  scope "/", MetgaugeWeb do
    pipe_through [:landing]
    get "/", PageController, :index
    get "/privacy-policy", PageController, :privacy_policy
    get "/terms-of-use", PageController, :terms_of_use
  end

  scope "/admin", MetgaugeWeb do
    pipe_through [:admin, :require_authenticated_user]
    get "/", AdminController, :index
    get "/user_notifications", AdminController, :user_notifications
    get "/user_notifications_lazy", AdminController, :user_notifications_lazy
    get "/sudo_login/:user_id", Users.SessionController, :sudo_login
  end

  scope "/admin", MetgaugeWeb, as: :admin do
    # TODO: Check they're a seller?
    pipe_through [:api, :require_authenticated_user]
  end

  scope "/admin", MetgaugeWeb, as: :admin do
    # TODO: Check they're a seller?
    pipe_through [:admin, :require_authenticated_user]
    get "/report_widget", AdminController, :report_widget
    get "/profile/edit", ProfileController, :edit
    put "/profile", ProfileController, :update
    resources "/clients", ClientController
    post "/clients/:id", ClientController, :update
    get "/users/filter", UserController, :filter
    delete "/users/:id/toggle_deactivate", UserController, :toggle_deactivate
    resources "/users", UserController
    post "/users/:id", UserController, :update
    post "/users/:id/confirm", UserController, :confirm
  end

  scope "/auth", MetgaugeWeb.Users, as: :user do
    pipe_through [:registration, :redirect_if_user_is_authenticated]

    get "/register", RegistrationController, :new
    get "/register/:client_slug", RegistrationController, :new
    post "/register", RegistrationController, :create
    get "/sign_in", SessionController, :new
    post "/sign_in", SessionController, :create
  end

  scope "/auth", MetgaugeWeb.Users, as: :user do
    pipe_through [:browser, :require_authenticated_user]

    get "/settings", SettingsController, :edit
    put "/settings", SettingsController, :update
    get "/settings/confirm_email/:token", SettingsController, :confirm_email
  end

  scope "/oauth", MetgaugeWeb.Users, as: :user do
    pipe_through [:browser, :registration]

    get "/:provider", OauthController, :request
    get "/:provider/callback", OauthController, :callback
  end

  scope "/auth", MetgaugeWeb.Users, as: :user do
    pipe_through [:password_reset, :redirect_if_user_is_authenticated]

    get "/reset_password", ResetPasswordController, :new
    post "/reset_password", ResetPasswordController, :create
    get "/reset_prompt", ResetPasswordController, :prompt
    get "/reset_password/:token", ResetPasswordController, :edit
    put "/reset_password/:token", ResetPasswordController, :update
  end

  scope "/auth", MetgaugeWeb.Users, as: :user do
    pipe_through [:registration]

    get "/sign_out", SessionController, :delete
    delete "/sign_out", SessionController, :delete

    get "/confirm", ConfirmationController, :new
    post "/confirm", ConfirmationController, :create
    get "/halt", ConfirmationController, :halt
  end

  ## ---------------------------------------------------------
  ## Development stuff
  ## ---------------------------------------------------------

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MetgaugeWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp put_layout_class(conn, class) do
    conn |> assign(:layout_class, class)
  end
end
