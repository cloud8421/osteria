defmodule Osteria.TableMap do
  def start_link do
    Agent.start_link(fn() -> %{} end, name: __MODULE__)
  end

  def register(pid, table_number) do
    Agent.update(__MODULE__, fn(current) ->
      Map.put(current, table_number, pid)
    end)
  end

  def where_is(table_number) do
    Agent.get(__MODULE__, fn(current) ->
      Map.get(current, table_number)
    end)
  end
end
