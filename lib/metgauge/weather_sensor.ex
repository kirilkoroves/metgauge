defmodule Metgauge.WeatherSensor do
  use GenServer
  require Logger

  @retry_interval 5_000

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    interval = Application.get_env(:metgauge, :interval, 1000)
    emqtt_opts = Application.get_env(:metgauge, :emqtt, %{
      host: "localhost",
      port: 1883,
      clientid: "metgauge_sensor"
    })

    report_topic = "reports/#{emqtt_opts[:clientid]}/temperature"

    state =
      Map.merge(state, %{
        interval: interval,
        timer: nil,
        report_topic: report_topic,
        emqtt_opts: emqtt_opts,
        pid: nil
      })

    {:ok, state, {:continue, :connect_emqtt}}
  end

  def handle_continue(:connect_emqtt, st) do
    case :emqtt.start_link(st.emqtt_opts) do
      {:ok, pid} ->
        connect_emqtt(pid, st)

      {:error, reason} ->
        Logger.warn("EMQTT start failed: #{inspect(reason)}, retrying in #{@retry_interval}ms")
        Process.send_after(self(), :retry_emqtt, @retry_interval)
        {:noreply, st}
    end
  end

  def handle_info(:retry_emqtt, st) do
    {:noreply, st, {:continue, :connect_emqtt}}
  end

  def handle_info(:tick, %{report_topic: topic, pid: pid} = st) do
    report_temperature(pid, topic)
    {:noreply, set_timer(st)}
  end

  def handle_info({:publish, %{topic: topic, payload: payload}}, st) do
    case String.split(topic, "/", trim: true) do
      ["commands", _, "set_interval"] ->
        interval = String.to_integer(payload)
        Logger.info("Received new interval: #{interval}ms")
        st = %{st | interval: interval} |> set_timer()
        {:noreply, st}

      _ ->
        {:noreply, st}
    end
  end

  # Private helpers
  defp connect_emqtt(pid, st) do
    case :emqtt.connect(pid) do
      {:ok, _} ->
        Logger.info("EMQTT connected")
        clientid = st.emqtt_opts[:clientid]

        case :emqtt.subscribe(pid, {"commands/#{clientid}/set_interval", 1}) do
          {:ok, _, _} ->
            Logger.info("Subscribed to interval command topic")
          {:error, reason} ->
            Logger.warn("Failed to subscribe: #{inspect(reason)}")
        end

        st = %{st | pid: pid} |> set_timer()
        {:noreply, st}

      {:error, reason} ->
        Logger.warn("EMQTT connect failed: #{inspect(reason)}, retrying in #{@retry_interval}ms")
        Process.send_after(self(), :retry_emqtt, @retry_interval)
        {:noreply, st}
    end
  end

  defp set_timer(st) do
    if st.timer, do: Process.cancel_timer(st.timer)
    timer = Process.send_after(self(), :tick, st.interval)
    %{st | timer: timer}
  end

  defp report_temperature(nil, _topic), do: :noop
  defp report_temperature(pid, topic) do
    temp = 10.0 + 2.0 * :rand.normal()
    payload = :erlang.term_to_binary({System.system_time(:millisecond), temp})
    :emqtt.publish(pid, topic, payload)
    Logger.debug("Published temperature #{temp} to #{topic}")
  end
end
