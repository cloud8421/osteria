defmodule Osteria.Waiter do
  alias Experimental.GenStage
  alias Osteria.Order

  require Logger

  use GenStage

  def collect_order(table_number, dishes) do
    order = %Order{table_number: table_number,
                   to_prepare: dishes}
    GenStage.call(__MODULE__, {:new_order, order})
  end

  def deliver_dish(table_number, dish) do
    GenStage.cast(__MODULE__, {:deliver_dish, table_number, dish})
  end

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:new_order, order}, from, {queue, demand}) do
    dispatch_orders(:queue.in({from, order}, queue), demand, [])
  end

  def handle_cast({:deliver_dish, table_number, dish}, state) do
    Osteria.Log.log_table_delivery(table_number, dish)
    Osteria.Table.receive_dish(table_number, dish)
    {:noreply, [], state}
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_orders(queue, incoming_demand + demand, [])
  end

  defp dispatch_orders(queue, demand, orders) do
    with d when d > 0 <- demand,
         {item, queue} = :queue.out(queue),
         {:value, {from, order}} <- item do
      GenStage.reply(from, :ok)
      Osteria.Log.log_table_order(order.table_number, order.to_prepare)
      dispatch_orders(queue, demand - 1, [order | orders])
    else
      _ -> {:noreply, Enum.reverse(orders), {queue, demand}}
    end
  end
end
