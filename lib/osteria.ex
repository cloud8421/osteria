defmodule Osteria do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Osteria.Table, [1, 3], id: 1),
      worker(Osteria.Table, [2, 4], id: 2),
      worker(Osteria.Table, [3, 7], id: 3),
      worker(Osteria.Table, [4, 2], id: 4),
      worker(Osteria.Table, [5, 3], id: 5),
      worker(Osteria.Table, [6, 4], id: 6),
      worker(Osteria.Table, [7, 2], id: 7),
      worker(Osteria.Waiter, []),
      worker(Osteria.Chef, [])
      # Starts a worker by calling: Osteria.Worker.start_link(arg1, arg2, arg3)
      # worker(Osteria.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one,
            max_restarts: 10,
            max_seconds: 5,
            name: Osteria.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
