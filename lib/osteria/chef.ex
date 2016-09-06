defmodule Osteria.Chef do
  alias Experimental.GenStage
  use GenStage

  alias Osteria.Menu

  @default_organizing_speed 100

  def start_link do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :ok = GenStage.async_subscribe(__MODULE__, to: Osteria.Waiter,
                                               min_demand: 3,
                                               max_demand: 5)
    {:producer_consumer, [],
     dispatcher: {GenStage.PartitionDispatcher,
                  partitions: 4,
                  hash: &partition/2}}
  end

  def handle_events(orders, _from, state) do
    Osteria.Status.update_chef(orders)
    dishes = extract_dishes(orders)
    organize_orders(orders)

    {:noreply, dishes, orders}
  end

  defp extract_dishes(orders) do
    Enum.flat_map(orders, fn(order) ->
      Enum.map(order.to_prepare, fn(dish_name) ->
        {order.table_number, Menu.find_by_name(dish_name)}
      end)
    end)
  end

  defp organize_orders([]), do: []

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

  defp partition({table_number, dish}, _line_cooks_total) do
    {{table_number, dish}, Osteria.LineCook.partition(dish.type)}
  end
end
