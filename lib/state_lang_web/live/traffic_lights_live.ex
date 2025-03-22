defmodule StateLangWeb.TrafficLightsLive do
  import FSMLiveGenerator
  alias StateLang.States.TrafficLights

  # https://www.erlang.org/docs/23/design_principles/statem#event-driven-state-machines
  # State(S) x Event(E) -> Actions(A), State(S')

  TrafficLights.state_machine() |> generate_liveview()
end
