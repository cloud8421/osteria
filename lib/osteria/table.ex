defmodule Osteria.Table do
  use GenServer

  defstruct number: 0,
            size: 0,
            dishes: []

  @default_thinking_time_range 1000..10000
  @default_waiting_time 10000

  def start_link(number, size) do
    GenServer.start_link(__MODULE__, [number, size], [])
  end

  def init([number, size]) do
    Osteria.Log.log_table_sitting(number)
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
                                               dishes: dishes}) do
    case length(dishes) do
      ^size ->
        inform_waiter(number, dishes)
        {:noreply, state, waiting_time()}
      _ ->
        schedule_decide()
        new_dish = random_dish()
        Osteria.Log.log_table_decision(number, new_dish)
        {:noreply, %__MODULE__{state | dishes: [new_dish | dishes]}}
    end
  end

  def handle_info(:timeout, state = %__MODULE__{number: number}) do
    Osteria.Log.log_table_leaving(number)
    {:stop, :normal, state}
  end

  defp schedule_decide do
    time = Enum.random(thinking_time_range())
    Process.send_after(self(), :decide, time)
  end

  defp random_dish do
    Osteria.Menu.names |> Enum.random()
  end

  defp thinking_time_range do
    Application.get_env(:osteria, __MODULE__)
    |> Keyword.get(:thinking_time_range, @default_thinking_time_range)
  end

  defp waiting_time do
    Application.get_env(:osteria, __MODULE__)
    |> Keyword.get(:waiting_time, @default_waiting_time)
  end

  defp inform_waiter(table_number, dishes) do
    Osteria.Waiter.collect_order(table_number, dishes)
  end
end
