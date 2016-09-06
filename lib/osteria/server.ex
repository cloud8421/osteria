defmodule Osteria.Server do
  use Plug.Router

  plug Plug.Static,
    at: "/assets",
    from: "frontend/build"

  plug :match

  match _ do
    send_resp(conn, 404, "not found")
  end
end
