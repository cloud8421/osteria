defmodule Osteria.Server do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/status" do
    send_resp(conn, 200, Poison.encode!(Osteria.Status.get))
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
