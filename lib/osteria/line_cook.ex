defmodule Osteria.LineCook do
  alias Experimental.GenStage
  use GenStage

  def partition(:pasta), do: 0
  def partition(:stew), do: 1
  def partition(:oven), do: 2
  def partition(:grill), do: 3

  def start_link(area) do
    GenStage.start_link(__MODULE__, area)
  end

  def init(area) do
    :ok = GenStage.async_subscribe(self(), to: Osteria.Chef,
                                           min_demand: 1,
                                           max_demand: 2,
                                           partition: partition(area))
    {:consumer, area}
  end

  def handle_events(dishes, _from, area) do
    Enum.map(dishes, fn(dish) ->
      Osteria.Log.log_line_cook_preparation(dish, area)
    end)
    {:noreply, [], area}
  end
end
