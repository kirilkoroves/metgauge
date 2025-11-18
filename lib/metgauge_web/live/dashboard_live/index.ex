defmodule MetgaugeWeb.DashboardLive.Index do
  use MetgaugeWeb, :live_view

  alias Metgauge.MQTTClient
  require Logger


  @impl true
  def mount(_params, %{"profile" => profile, "user" => user} = _session, socket) do
    reports = []
    topic = "devices/#{user.client.slug}/temperatures"
    MQTTClient.subscribe(topic)
    topic = "devices/#{user.client.slug}/measurement_status"
    MQTTClient.subscribe(topic)
    topic = "devices/#{user.client.slug}/points"
    MQTTClient.subscribe(topic)
    topic = "devices/#{user.client.slug}/temperature_status"
    MQTTClient.subscribe(topic)
    topic = "devices/#{user.client.slug}/hazard_status"
    MQTTClient.subscribe(topic)
    topic = "devices/#{user.client.slug}/light_status"
    MQTTClient.subscribe(topic)
    Phoenix.PubSub.subscribe(Metgauge.PubSub, "mqtt:messages")

    {:ok, assign(socket,
      profile: profile,
      user: user,
      reports: reports,
      plot: nil,
      plot_vertical: nil,
      dataset_measurement_statuses: [],
      interval: nil,
      points: [],
      points_img: nil,
      temperature_status: "none",
      hazard_status: "none",
      light_status: "none"
    )}
  end

  @impl true
  def handle_event("set-interval", %{"interval" => interval_s}, socket) do
    case Integer.parse(interval_s) do
      {interval, ""} ->
        points = Metgauge.MQTTClient.generate_circle_points(150, interval)
        points = points ++ [Enum.at(points, 0)]
        spawn(fn -> 
          for i <- 0..(interval) do
            Metgauge.MQTTClient.report_temperature("devices/#{socket.assigns.user.client.slug}/temperatures")
            Metgauge.MQTTClient.report_measurement_status("devices/#{socket.assigns.user.client.slug}/measurement_status")
            Metgauge.MQTTClient.report_points("devices/#{socket.assigns.user.client.slug}/points", Enum.at(points, i))
            :timer.sleep(1000)
            if rem(i, 3) == 0 do
              Metgauge.MQTTClient.report_params_status("devices/#{socket.assigns.user.client.slug}/temperature_status")
              Metgauge.MQTTClient.report_params_status("devices/#{socket.assigns.user.client.slug}/hazard_status")
              Metgauge.MQTTClient.report_params_status("devices/#{socket.assigns.user.client.slug}/light_status")
            end
          end
        end)
        {:noreply, assign(socket, interval: interval)}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event(name, data, socket) do
    Logger.info("handle_event: #{inspect([name, data])}")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:publish, %{topic: topic, message: message}}, socket) do
    split_topic = String.split(topic, "/")
    handle_graph(:publish, Enum.at(split_topic,1), Enum.at(split_topic, 2), message, socket) 
  end

  defp handle_graph(:publish, slug, "temperatures", payload, socket) do
    if slug == socket.assigns.user.client.slug do
      {reports, plot} = update_reports(payload, socket)
      {:noreply, assign(socket, reports: reports, plot: plot)}
    else
      {:noreply, socket}
    end
  end

  defp handle_graph(:publish, slug, "measurement_status", payload, socket) do
    if slug == socket.assigns.user.client.slug do
      {dataset_measurement_statuses, plot_vertical} = update_measurement_statuses(payload, socket)
      {:noreply, assign(socket, dataset_measurement_statuses: dataset_measurement_statuses, plot_vertical: plot_vertical)}
    else
      {:noreply, socket}
    end
  end

  defp handle_graph(:publish, slug, topic, payload, socket) when topic in ["temperature_status", "hazard_status", "light_status"] do
    if slug == socket.assigns.user.client.slug do
      colors_map = %{"red" => "#ff0000", "green" => "#00ff00", "yellow" => "#ffff00"}
      color = colors_map[payload]
      {:noreply, assign(socket, String.to_atom(topic), color)}
    else
      {:noreply, socket}
    end
  end

  defp handle_graph(:publish, slug, "points", payload, socket) do
    if slug == socket.assigns.user.client.slug do
      {points, points_img} = update_points(payload, socket)
      {:noreply, assign(socket, points: points, points_img: points_img)}
    else
      {:noreply, socket}
    end
  end

  def update_points(point, socket) do
    points = socket.assigns.points ++ [point]
    points_str =
      points   |> Enum.map(fn {x, y} -> "#{x + 200},#{y + 200}" end) |> Enum.join(" ")

    points_img = """
    <svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">
      <polyline points="#{points_str}" fill="none" stroke="blue" stroke-width="2"/>
    </svg>
    """

    {points, points_img}
  end

  defp update_measurement_statuses(status, socket) do
    dataset_measurement_statuses = socket.assigns[:dataset_measurement_statuses]
    last_measurement_status = List.last(dataset_measurement_statuses)
    dataset_measurement_statuses = 
      if last_measurement_status != nil do
        if last_measurement_status.status == status do
          List.delete_at(dataset_measurement_statuses, length(dataset_measurement_statuses)-1) ++ [%{status: status, count: last_measurement_status.count+1}]
        else
          dataset_measurement_statuses ++ [%{status: status, count: 1}]
        end
      else
        [%{status: status, count: 1}]
      end

    colors_map = %{"red" => "ff0000", "green" => "00ff00", "yellow" => "ffff00"}

    values = dataset_measurement_statuses |> Enum.map(&(&1.count))
    colors = dataset_measurement_statuses |> Enum.map(&(colors_map[&1.status]))
    data = [
      [""] ++ values
    ]
    IO.inspect(data)
    series_cols = for i <- 1..length(values), do: "x#{i}"
    dataset = Contex.Dataset.new(data, ["Category" | series_cols])
    IO.inspect(dataset)


    options = [
      mapping: %{category_col: "Category", value_cols: series_cols},
      type: :stacked,           # stacked is the default, but it's clearer to set it
      data_labels: false,
      colour_palette: colors,
      orientation: :horizontal,
      display_decimals: false,
      show_y_axis: false,
      show_x_axis: true
    ]
    # Wrap into a Plot (width x height)
    plot_vertical = 
      Contex.Plot.new(dataset, Contex.BarChart, 600, 200, options) 
      |> Contex.Plot.to_svg()
    {dataset_measurement_statuses, plot_vertical}
  end

  defp update_reports({ts, val}, socket) do
    new_report = {DateTime.from_unix!(ts, :millisecond), val}
    first = socket.assigns[:reports] |> Enum.sort() |> Enum.at(0)
    now = 
      if first == nil do
        DateTime.from_unix!(ts, :millisecond)
      else
        {ts, _val} = first
        ts
      end
    deadline = DateTime.add(DateTime.from_unix!(ts, :millisecond) , -1, :second)
    reports =
      [new_report | socket.assigns[:reports]]
      |> Enum.sort()

    {reports, plot(reports, deadline, now)}
  end

  defp plot(reports, deadline, now) do
    x_scale =
      Contex.TimeScale.new()
      |> Contex.TimeScale.domain(deadline, now)
      |> Contex.TimeScale.interval_count(10)

    y_scale =
      Contex.ContinuousLinearScale.new()
      |> Contex.ContinuousLinearScale.domain(0, 30)

    options = [
      smoothed: false,
      custom_x_scale: x_scale,
      custom_y_scale: y_scale,
      custom_x_formatter: &x_formatter/1,
      axis_label_rotation: 45
    ]

    reports
    |> Enum.map(fn {dt, val} -> [dt, val] end)
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.LinePlot, 600, 250, options)
    |> Contex.Plot.to_svg()
  end

  defp x_formatter(datetime) do
    datetime
    |> Calendar.strftime("%H:%M:%S")
  end
end
