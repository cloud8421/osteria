defmodule Osteria.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    tables = Enum.map((1..10), fn(i) ->
      worker(Osteria.Table, [i, Enum.random((1..10))], id: i)
    end)

    # Define workers and child supervisors to be supervised
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Osteria.Server, [], [port: 4001, dispatch: dispatch()]),
      supervisor(Registry, [:unique, Osteria.TableRegistry]),
      worker(Osteria.Status, []),
      worker(Osteria.Waiter, []),
      worker(Osteria.Chef, []),
      worker(Osteria.LineCook, [:grill], id: :grill),
      worker(Osteria.LineCook, [:pasta], id: :pasta),
      worker(Osteria.LineCook, [:stew], id: :stew),
      worker(Osteria.LineCook, [:oven], id: :oven)
      # Starts a worker by calling: Osteria.Worker.start_link(arg1, arg2, arg3)
      # worker(Osteria.Worker, [arg1, arg2, arg3]),
    ] ++ tables

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one,
            max_restarts: 20,
            max_seconds: 5,
            name: Osteria.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_, [
        {"/ws", Osteria.SocketHandler, []},
        {:_, Plug.Adapters.Cowboy.Handler, {Osteria.Server, []}}
      ]}
    ]
  end
end
