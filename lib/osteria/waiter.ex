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

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer, {[], 0}}
  end

  def handle_demand(incoming_demand, {orders, demand}) do
    {demanded, rest} = Enum.split(orders, incoming_demand + demand)
    {:noreply, demanded, {rest, incoming_demand}}
  end

  def handle_call({:new_order, order}, from, {orders, demand}) do
    GenStage.reply(from, :ok)
    Osteria.Log.log_table_order(order.table_number, order.to_prepare)
    new_orders = [order | orders]
    {demanded, rest} = Enum.split(new_orders, demand)
    {:noreply, demanded, {rest, demand}}
  end
end
