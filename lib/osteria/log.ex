defmodule Osteria.Log do
  import IO.ANSI

  def log_table_decision(number, dish) do
    "Table #{number} decided for #{dish}"
    |> colorize(yellow())
    |> IO.puts
  end

  def log_table_order(number, to_prepare) do
    "Table #{number} is ready with: #{inspect to_prepare}"
    |> colorize(cyan())
    |> IO.puts
  end

  def log_chef_organization(orders) do
    tables = orders
             |> Enum.map(&(&1.table_number))
             |> Enum.join("-")
   "Chef organized orders for tables: #{tables}"
   |> colorize(magenta())
   |> IO.puts
  end

  defp colorize(msg, color) do
    [color, msg, white()] |> Enum.join("")
  end
end
