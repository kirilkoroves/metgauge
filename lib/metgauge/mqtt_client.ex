defmodule Metgauge.MQTTClient do
  use GenServer

  ## Public API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def subscribe(topic) do
    GenServer.cast(__MODULE__, {:subscribe, topic})
  end

  def publish(topic, payload) do
    GenServer.cast(__MODULE__, {:publish, topic, payload})
  end

  ## GenServer Callbacks

  def init(_) do
    {:ok, connect()}
  end

  # Connect and attach listener
  defp connect() do
    client_id = Application.get_env(:metgauge, :mqtt_client_id)
    host = Application.get_env(:metgauge, :mqtt_host)
    port = Application.get_env(:metgauge, :mqtt_port)
    clean_start = Application.get_env(:metgauge, :mqtt_clean_start)

    {:ok, pid} =
      :emqtt.start_link(
        host: host,
        port: port,
        clientid: client_id,
        clean_start: clean_start
      )

    {:ok, _} = :emqtt.connect(pid)
    IO.puts("MQTT connected: #{client_id}")

    %{mqtt: pid, subs: MapSet.new()}
  end

  # Reconnect on crash
  def handle_info({:EXIT, _pid, _reason}, _state) do
    IO.puts("MQTT disconnected, reconnecting...")
    {:noreply, connect()}
  end

  # Incoming MQTT messages
  def handle_info({:publish, %{payload: message, topic: topic}}, state) do
    message = :erlang.binary_to_term(message)
    IO.puts("Received message on #{topic}: #{inspect(message)}")
    Phoenix.PubSub.broadcast(
      Metgauge.PubSub,
      "mqtt:messages",
      {:publish, %{topic: topic, message: message}}
    )
    {:noreply, state}
  end

  ## Dynamic Subscribe
  def handle_cast({:subscribe, topic}, state) do
    :emqtt.subscribe(state.mqtt, %{}, [{topic, []}])

    new_state = %{state | subs: MapSet.put(state.subs, topic)}

    IO.puts("Subscribed to #{topic}")
    {:noreply, new_state}
  end

  ## Publish
  def handle_cast({:publish, topic, payload}, state) do
    :emqtt.publish(state.mqtt, topic, payload)
    {:noreply, state}
  end

  def report_temperature(topic) do
    temperature = 10.0 + 2.0 * :rand.normal()
    message = {System.system_time(:millisecond), temperature}
    payload = :erlang.term_to_binary(message)
    Metgauge.MQTTClient.publish(topic, payload)
  end

  def report_measurement_status(topic) do
    measurement_status = Enum.random(["red", "green", "green", "yellow", "green", "yellow", "green", "red", "green", "green", "yellow", "green", "green"])
    payload = :erlang.term_to_binary(measurement_status)
    Metgauge.MQTTClient.publish(topic, payload)
  end

  def report_params_status(topic) do
    measurement_status = Enum.random(["red", "green", "yellow"])
    payload = :erlang.term_to_binary(measurement_status)
    Metgauge.MQTTClient.publish(topic, payload)
  end

  def report_points(topic, point) do
    payload = :erlang.term_to_binary(point)
    Metgauge.MQTTClient.publish(topic, payload)
  end

  def generate_circle_points(r, n_points) do
    cx = 0
    cy = 0
    0..(n_points - 1)
    |> Enum.map(fn i ->
      angle = 2 * :math.pi() * i / n_points
      {cx + r * :math.cos(angle), cy + r * :math.sin(angle)}
    end)
  end
end
