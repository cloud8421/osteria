defmodule Osteria.Log do
  import IO.ANSI

  def log_table_decision(number, dish) do
    "Table #{number} decided for #{dish}"
    |> colorize(yellow())
    |> log
  end

  def log_table_order(number, to_prepare) do
    "Table #{number} is ready with: #{inspect to_prepare}"
    |> colorize(cyan())
    |> log
  end

  def log_table_sitting(number) do
    "Table #{number} is choosing dishes"
    |> colorize(white())
    |> log
  end

  def log_table_leaving(number) do
    "Table #{number} has waited too long, people decided to leave"
    |> colorize(red())
    |> log
  end

  def log_chef_organization(orders) do
    tables = orders
             |> Enum.map(&(&1.table_number))
             |> Enum.join("-")
   "Chef organized orders for tables: #{tables}"
   |> colorize(magenta())
   |> log
  end

  def log_line_cook_preparation({table_number, dish}, area) do
    "Line cook for #{area} prepared #{dish.name} for table: #{table_number}"
    |> colorize(green())
    |> log
  end

  def log_table_delivery(table_number, dish) do
    "Waiter delivering #{dish.name} to table #{table_number}"
    |> colorize(blue())
    |> log
  end

  def log_table_receive(table_number, dish) do
    "Table #{table_number} received #{dish.name}"
    |> colorize(yellow())
    |> log
  end

  def log_table_received_all(table_number) do
    "Table #{table_number} received all dishes, now eating!"
    |> colorize(yellow())
    |> log
  end

  def log_table_finish(table_number) do
    "Table #{table_number} finished eating!"
    |> colorize(white())
    |> log
  end

  defp colorize(msg, color) do
    [color, msg, white()] |> Enum.join("")
  end

  defp log(msg) do
    IO.puts msg
  end
end
