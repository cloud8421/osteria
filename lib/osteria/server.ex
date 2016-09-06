defmodule Osteria.Server do
  use Plug.Router

  plug Plug.Static,
    at: "/assets",
    from: "frontend/build"

  plug :match
  plug :dispatch

  get "/status" do
    body = Osteria.Status.get
           |> serialize_status
           |> Poison.encode!
    send_resp(conn, 200, body)
  end

  match _ do
    send_resp(conn, 404, "not found")
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
