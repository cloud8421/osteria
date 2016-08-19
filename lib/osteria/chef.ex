defmodule Osteria.Chef do
  alias Experimental.GenStage
  use GenStage

  @default_organizing_speed 100

  def start_link do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :ok = GenStage.async_subscribe(__MODULE__, to: Osteria.Waiter,
                                               min_demand: 1,
                                               max_demand: 2)
    {:consumer, []}
  end

  def handle_events(orders, _from, state) do
    organize_orders(orders)
    {:noreply, [], [orders | state]}
  end

  defp organize_orders(orders) do
    do_organize_orders(orders)
    Osteria.Log.log_chef_organization(orders)
  end

  defp do_organize_orders(orders) do
    time = Enum.reduce(orders, 0, fn(order, acc) ->
      acc + length(order.to_prepare)
    end) * organizing_speed()
    Process.sleep(time)
  end

  defp organizing_speed do
    Application.get_env(:osteria, __MODULE__)
    |> Keyword.get(:organizing_speed, @default_organizing_speed)
  end
end
