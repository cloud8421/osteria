defmodule Osteria.LineCook do
  use GenStage

  @default_cooking_speed 1500

  def partition(:pasta), do: 0
  def partition(:stew), do: 1
  def partition(:oven), do: 2
  def partition(:grill), do: 3

  def start_link(area) do
    GenStage.start_link(__MODULE__, area)
  end

  def init(area) do
    :ok = GenStage.async_subscribe(self(), to: Osteria.Chef,
                                           min_demand: 3,
                                           max_demand: 5,
                                           partition: area)
    {:consumer, area}
  end

  def handle_events(dish_tuples, _from, area) do
    update_status(dish_tuples, area)
    Enum.map(dish_tuples, fn({table_number, dish}) ->
      Process.sleep(cooking_speed())
      Osteria.Log.log_line_cook_preparation({table_number, dish}, area)
      Osteria.Waiter.deliver_dish(table_number, dish)
    end)
    {:noreply, [], area}
  end

  defp update_status(dish_tuples, area) do
    dish_tuples
    |> Enum.map(fn({_, dish}) -> dish end)
    |> Osteria.Status.update_line_cook(area)
  end

  defp cooking_speed do
    Application.get_env(:osteria, __MODULE__)
    |> Keyword.get(:cooking_speed, @default_cooking_speed)
  end
end
