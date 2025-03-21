defmodule StateLangWeb.TodoLive do
  import FSMLiveGenerator
  alias StateLang.States.Todo

  # https://www.erlang.org/docs/23/design_principles/statem#event-driven-state-machines
  # State(S) x Event(E) -> Actions(A), State(S')

  Todo.state_machine() |> generate_liveview()
end
