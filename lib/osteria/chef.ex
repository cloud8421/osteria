defmodule Osteria.Chef do
  alias Experimental.GenStage
  use GenStage

  @default_organizing_speed 100
  @warmup_time 1000

  def start_link do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Process.send_after(self(), :start_waiting, @warmup_time)
    {:consumer, []}
  end

  def handle_events(:new_order, _from, state) do
    {:noreply, [], state}
  end
  def handle_events([:new_order], _from, state) do
    {:noreply, [], state}
  end
  def handle_events(orders, _from, state) do
    organize_orders(orders)
    {:noreply, [], [orders | state]}
  end

  def handle_info(:start_waiting, state) do
    :ok = GenStage.async_subscribe(__MODULE__, to: Osteria.Waiter,
                                               min_demand: 0,
                                               max_demand: 2)
    {:noreply, [], state}
  end

  defp organize_orders(orders) do
    time = Enum.reduce(orders, 0, fn(order, acc) ->
      acc + length(order.to_prepare)
    end) * organizing_speed()
    Osteria.Log.log_chef_organization(orders)
    :timer.sleep(time)
  end

  defp organizing_speed do
    Application.get_env(:osteria, __MODULE__)
    |> Keyword.get(:organizing_speed, @default_organizing_speed)
  end
end
