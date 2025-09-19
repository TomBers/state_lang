defmodule StateLangWeb.PageController do
  use StateLangWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def index(conn, params) do
    topic = "Elixir.StateLang.States." <> params["topic"]

    Phoenix.PubSub.broadcast(
      StateLang.PubSub,
      topic,
      {:message, params}
    )

    json(conn, %{message: "Hello, Publish"})
  end
end
