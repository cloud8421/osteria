defmodule Osteria.Table do
  use GenServer

  require Logger

  defstruct number: 0,
            size: 0,
            orders: []

  @default_thinking_time_range 1000..10000
  @dishes ["spaghetti all'amatriciana",
           "spaghetti alla carbonara",
           "polenta e cotechino",
           "arrosto di vitello"]

  def start_link(number, size) do
    GenServer.start_link(__MODULE__, [number, size], [])
  end

  def init([number, size]) do
    :rand.seed(:exsplus, :os.timestamp)
    state = %__MODULE__{number: number,
                        size: size}
    send(self(), :look_at_menu)
    {:ok, state}
  end

  def handle_info(:look_at_menu, state) do
    schedule_decide()
    {:noreply, state}
  end

  def handle_info(:decide, state = %__MODULE__{number: number,
                                               size: size,
                                               orders: orders}) do
    case length(orders) do
      ^size ->
        Logger.info "table=#{number} is ready with: #{inspect orders}"
        {:noreply, state}
      _ ->
        schedule_decide()
        {:noreply, %__MODULE__{state | orders: [random_dish() | orders]}}
    end
  end

  defp schedule_decide do
    time = Enum.random(thinking_time_range())
    Process.send_after(self(), :decide, time)
  end

  defp random_dish do
    Enum.random(@dishes)
  end

  defp thinking_time_range do
    Application.get_env(:osteria, __MODULE__)
    |> Keyword.get(:thinking_time_range, @default_thinking_time_range)
  end
end
