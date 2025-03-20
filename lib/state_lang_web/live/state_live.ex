defmodule StateLangWeb.StateLive do
  # use StateLangWeb, :live_view
  import FSMLiveGenerator

  prog = %{
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
      },
      %{
        "name" => "Add num",
        "transition" => "add_num",
        "type" => "button"
      }
    ],
    "initial_state" => %{"count" => 0, "num" => 0, "name" => "initial_state"},
    "transitions" => [
      {"addition", "count", "+ 1"},
      {"double_addition", "count", " + 2"},
      {"subtraction", "count", "- 1"},
      {"add_num", "num", "+ 1"}
    ]
  }

  generate_liveview(prog)
end
