defmodule StateLangWeb.StateLive do
  import FSMLiveGenerator
  alias StateLang.States.StateTest

  # https://www.erlang.org/docs/23/design_principles/statem#event-driven-state-machines
  # State(S) x Event(E) -> Actions(A), State(S')

  StateTest.state_machine() |> generate_liveview()
end
