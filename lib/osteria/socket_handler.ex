defmodule Osteria.SocketHandler do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60000 # terminate if no activity for one minute

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    state = %{}
    Process.send_after(self(), :send_status, 500)
    {:ok, req, state, @timeout}
  end

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, _}, req, state) do
    {:ok, req, state}
  end

  def websocket_info(:send_status, req, state) do
    text = Osteria.Status.get
           |> serialize_status
           |> Poison.encode!
    Process.send_after(self(), :send_status, 500)
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

  defp serialize_status(status) do
    %{tables: Map.values(status.tables),
      chef: serialize_chef(status.chef),
      line_cooks: serialize_line_cooks(status.line_cooks)}
  end

  defp serialize_chef([chef_status]) do
    %{table_number: chef_status.table_number,
      orders: Map.get(chef_status, :to_prepare)}
  end

  defp serialize_line_cooks(line_cooks) do
    Enum.reduce(line_cooks, [], fn({area, dishes}, acc) ->
      dish_names = Enum.map(dishes, &(&1.name))
      entry = %{area: area, dishes: dish_names}
      [entry | acc]
    end)
  end
end
