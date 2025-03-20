defmodule StateLangWeb.StateLive do
  # use StateLangWeb, :live_view
  import FSMLiveGenerator

  generate_liveview(%{
    "components" => [
      %{
        "name" => "Increment",
        "transition" => "addition",
        "type" => "button"
      },
      %{
        "name" => "Double Increment",
        "transition" => "double_addition",
        "type" => "button"
      },
      %{
        "name" => "Decrement",
        "transition" => "subtraction",
        "type" => "button"
      }
    ],
    "initial_state" => %{"count" => 0, "name" => "initial_state"},
    "transitions" => [
      {"addition", "state.count + 1"},
      {"double_addition", "state.count + 2"},
      {"subtraction", "state.count - 1"}
    ]
  })
end
