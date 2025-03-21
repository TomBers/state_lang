defmodule StateLang.States.StateTest do
  @btn_style "rounded-md bg-black-800 py-2 px-4 border border-transparent text-center text-sm transition-all shadow-md hover:shadow-lg focus:bg-slate-700 focus:shadow-none active:bg-slate-700 hover:bg-slate-700 active:shadow-none disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none ml-2"

  def addition(state), do: %{state | count: state.count + 1}
  def double_addition(state), do: %{state | count: state.count + 2}
  def subtraction(state), do: %{state | count: state.count - 1}
  def add_num(state), do: %{state | num: state.num + 1}
  def reset(state), do: %{state | count: 0, num: 0}

  def state_machine do
    %{
      "components" => [
        %{
          "name" => "Increment",
          "transition" => "addition",
          "type" => "button",
          "style" => @btn_style
        },
        %{
          "name" => "Double Increment",
          "transition" => "double_addition",
          "type" => "button",
          "style" => @btn_style
        },
        %{
          "name" => "Decrement",
          "transition" => "subtraction",
          "type" => "button",
          "style" => @btn_style
        },
        %{
          "name" => "Add num",
          "transition" => "add_num",
          "type" => "button",
          "style" => @btn_style
        },
        %{
          "name" => "Reset",
          "transition" => "reset",
          "type" => "button",
          "style" => @btn_style
        }
      ],
      "initial_state" => %{"count" => 0, "num" => 0, "name" => "initial_state"},
      "module" => __MODULE__,
      "transitions" => [
        {"addition", :addition},
        {"double_addition", :double_addition},
        {"subtraction", :subtraction},
        {"add_num", :add_num},
        {"reset", :reset}
      ]
    }
  end
end
