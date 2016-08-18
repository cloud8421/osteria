defmodule Osteria.Waiter do
  alias Experimental.GenStage
  alias Osteria.Order

  require Logger

  use GenStage

  def collect_order(table_number, dishes) do
    send(__MODULE__, %Order{table_number: table_number,
                            to_prepare: dishes})
  end

  def start_link do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:producer, []}
  end

  def handle_demand(demand, orders) do
    {demanded, rest} = Enum.split(orders, demand)
    {:noreply, demanded, rest}
  end

  def handle_info(order, orders) do
    Osteria.Log.log_table_order(order.table_number, order.to_prepare)
    {:noreply, [:new_order], [order | orders]}
  end
end
