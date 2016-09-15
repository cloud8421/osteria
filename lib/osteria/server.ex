defmodule Osteria.Server do
  use Plug.Router

  plug Plug.Static,
    at: "/assets",
    from: "frontend/build"

  plug :match
  plug :dispatch

  get "/" do
    body = File.read!("frontend/build/index.html")
    send_resp(conn, 200, body)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
