defmodule Osteria.Table do
  use GenServer

  alias Osteria.TableMap

  defstruct number: 0,
            size: 0,
            dishes: []

  @default_thinking_time_range 1000..10000
  @default_waiting_time 15000

  def start_link(number, size) do
    GenServer.start_link(__MODULE__, [number, size], [])
  end

  def receive_dish(table_number, dish) do
    pid = TableMap.where_is(table_number)
    GenServer.cast(pid, {:receive_dish, dish})
  end

  def init([number, size]) do
    Osteria.Log.log_table_sitting(number)
    TableMap.register(self(), number)
    :rand.seed(:exsplus, :os.timestamp)
    state = %__MODULE__{number: number,
                        size: size}
    send(self(), :look_at_menu)
    {:ok, state}
  end

  def handle_cast({:receive_dish, dish}, state = %__MODULE__{number: number,
                                                             size: size,
                                                             dishes: dishes}) do
    Osteria.Log.log_table_receive(number, dish)
    new_dishes = List.delete(dishes, dish.name)
    case new_dishes do
      [] ->
        Osteria.Log.log_table_received_all(number)
        Process.send_after(self(), :finished_eating, eating_time(size))
        {:noreply, %{state | dishes: []}}
      some_left ->
        {:noreply, %{state | dishes: new_dishes}, waiting_time()}
    end
  end

  def handle_info(:look_at_menu, state) do
    schedule_decide()
    {:noreply, state}
  end

  def handle_info(:finished_eating, state = %__MODULE__{number: number}) do
    Osteria.Log.log_table_finish(number)
    {:stop, :normal, state}
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
    {:stop, :waited_too_long, state}
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

  defp eating_time(size) do
    size * 200
  end

  defp inform_waiter(table_number, dishes) do
    Osteria.Waiter.collect_order(table_number, dishes)
  end
end
