defmodule MetgaugeWeb.AdminView do
  use MetgaugeWeb, :view

  def profile_image_url(conn, profile) do
    if profile == nil or profile.avatar_path == "" or profile.avatar_path == nil do
      Routes.static_path(conn, "/assets/svg/generic/no_profile_photo.svg")
    else
      Routes.static_path(conn, "/uploads/#{profile.avatar_path}")
    end
  end

  def notification_title("booking"), do: gettext("New booking")
  def notification_title("cancel_booking"), do: gettext("Canceled booking")
  def notification_title("notification"), do: gettext("Booking notification")
  def notification_title("service"), do: gettext("Service notification")
  def notification_title("payment"), do: gettext("Payment notification")

  def user_notification_datetime(conn, user_notification) do
    if conn.assigns[:profile] != nil and conn.assigns[:profile].timezone != "" and conn.assigns[:profile].timezone != nil do
      {:ok, start_time} = user_notification.inserted_at |> DateTime.from_naive("UTC")
      user_timezone = conn.assigns[:profile].timezone
      Timex.Timezone.convert(start_time, user_timezone)
    else
      user_notification.inserted_at
    end
  end

  def format_user_notification_datetime(conn, user_notification_datetime) do
    if conn.assigns[:profile] != nil and conn.assigns[:profile].timezone != "" and conn.assigns[:profile].timezone != nil do
      {:ok, start_time} = user_notification_datetime |> DateTime.from_naive("UTC")
      user_timezone = conn.assigns[:profile].timezone
      notification_datetime = Timex.Timezone.convert(start_time, user_timezone) |> Timex.to_date()
      today = Timex.Timezone.convert(Timex.now(), user_timezone)|> Timex.to_date()
      yesterday = Timex.Timezone.convert(Timex.shift(Timex.now(), days: -1), user_timezone)|> Timex.to_date()
        cond do
        Timex.compare(notification_datetime, today) == 0 ->
          gettext "Today"
        Timex.compare(notification_datetime, yesterday) == 0 ->
          gettext "Yesterday"
        true ->
          locale = Map.get(conn.assigns, :locale)
          notification_datetime |> Timex.lformat!("%b %d, %Y", locale, :strftime)
      end
    else
      user_notification_datetime |> Timex.to_date()
    end
  end

  def price_format(price) do
    currency = 
      case price.currency do
        :JPY -> "円"
        curr -> " #{curr}"
      end

    "#{Number.Delimit.number_to_delimited(price.amount, precision: 0)}#{currency}"
  end

  def email_datetime(datetime, locale) do
    datetime |> Timex.lformat!("%b %d, %y", locale, :strftime)
  end
end
