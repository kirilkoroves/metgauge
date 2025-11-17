defmodule MetgaugeWeb.Helpers.NotificationHelpers do
  require Logger
  
  def send_browser_notification(to, title, body, icon, click_action) do
    key = Application.get_env(:metgauge, :firebase_api_key)
    headers = %{
      "Content-Type" => "application/json",
      "Authorization" => "key=#{key}"
    }
    params = %{
      to: to,
      notification: %{
        icon: icon,
        title: title,
        body: body,
        click_action: click_action
      }
    }

    IO.inspect(params)
    case HTTPoison.post("https://fcm.googleapis.com/fcm/send", Poison.encode!(params), headers) do
      {:ok, _} -> :ok
      error -> 
        IO.inspect(error)
        :error
    end
  end
end
