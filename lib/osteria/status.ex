defmodule Osteria.Status do
  def start_link do
    initial = %{
      tables: %{},
      waiter_queue: 0,
      chef: [],
      line_cooks: %{},
      error_count: 0
    }
    Agent.start_link(fn() -> initial end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, fn(state) -> state end)
  end

  def update_table(table_state) do
    Agent.update(__MODULE__, fn(current) ->
      put_in(current, [:tables, to_string(table_state.number)], table_state)
    end)
  end

  def delete_table(table_number, :normal) do
    Agent.update(__MODULE__, fn(current) ->
      {_el, new_state}= pop_in(current, [:tables, to_string(table_number)])
      new_state
    end)
  end
  def delete_table(table_number, reason) do
    Agent.update(__MODULE__, fn(current) ->
      {_el, new_state}= pop_in(current, [:tables, to_string(table_number)])
      Map.update!(new_state, :error_count, &(&1 + 1))
    end)
  end

  def update_waiter(queue_length) do
    Agent.update(__MODULE__, fn(current) ->
      Map.put(current, :waiter_queue, queue_length)
    end)
  end

  def update_chef(chef_state) do
    Agent.update(__MODULE__, fn(current) ->
      put_in(current, [:chef], chef_state)
    end)
  end

  def update_line_cook(dishes, area) do
    Agent.update(__MODULE__, fn(current) ->
      put_in(current, [:line_cooks, area], dishes)
    end)
  end
end
