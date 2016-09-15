defmodule Osteria.SocketHandler do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60000 # terminate if no activity for one minute
  @refresh_interval 100

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    state = %{}
    schedule_refresh()
    {:ok, req, state, @timeout}
  end

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, text}, req, state) do
    handle_text(text)
    {:ok, req, state}
  end

  def websocket_info(:send_status, req, state) do
    text = Osteria.Status.get
           |> serialize_status
           |> Poison.encode!
    schedule_refresh()
    {:reply, {:text, text}, req, state}
  end

  # Format and forward elixir messages to client
  def websocket_info(message, req, state) do
    {:reply, {:text, message}, req, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, _state) do
    :ok
  end

  defp handle_text("slow-line-cook") do
    Osteria.Config.slow_line_cook
  end
  defp handle_text("fast-line-cook") do
    Osteria.Config.fast_line_cook
  end
  defp handle_text("slow-chef") do
    Osteria.Config.slow_chef
  end
  defp handle_text("fast-chef") do
    Osteria.Config.fast_chef
  end
  defp handle_text(_), do: :ok

  defp serialize_status(status) do
    %{tables: Map.values(status.tables),
      waiter_queue: status.waiter_queue,
      chef: serialize_chef(status.chef),
      line_cooks: serialize_line_cooks(status.line_cooks),
      error_count: status.error_count}
  end

  defp serialize_chef(chef_orders) do
    Enum.map(chef_orders, fn(chef_order) ->
      %{table_number: chef_order.table_number,
       orders: Map.get(chef_order, :to_prepare)}
    end)
  end

  defp serialize_line_cooks(line_cooks) do
    Enum.reduce(line_cooks, [], fn({area, dishes}, acc) ->
      dish_names = Enum.map(dishes, &(&1.name))
      entry = %{area: area, dishes: dish_names}
      [entry | acc]
    end)
  end

  defp schedule_refresh do
    Process.send_after(self(), :send_status, @refresh_interval)
  end
end
