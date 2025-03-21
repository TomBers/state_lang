defmodule StateLang.States.StateTest do
  @btn_style "rounded-md bg-black-800 py-2 px-4 border border-transparent text-center text-sm transition-all shadow-md hover:shadow-lg focus:bg-slate-700 focus:shadow-none active:bg-slate-700 hover:bg-slate-700 active:shadow-none disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none ml-2"

  # Transition functions
  # State(S) x Event(E) -> Actions(A), State(S')
  # These functions are triggered by an event and modify the state accordingly.
  # They (may take an action) then perform the action on the state.
  def addition(state, _), do: %{state | count: state.count + 1}
  def double_addition(state, _), do: %{state | count: state.count + 2}
  def subtraction(state, _), do: %{state | count: state.count - 1}
  def add_num(state, _), do: %{state | num: state.num + 1}
  def reset(state, _), do: %{state | count: 0, num: 0}

  def set_title(state, params),
    do: %{state | name: Map.get(params, "Text Inout") <> " #{state.count + state.num}"}

  # Output functions
  def title_state(state), do: state.name
  def count_state(state), do: state.count
  def num_state(state), do: state.num
  def total_state(state), do: state.count + state.num

  def state_machine do
    %{
      "initial_state" => %{"count" => 0, "num" => 0, "name" => "initial_state"},
      "module" => __MODULE__,
      "inputs" => [
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
        },
        %{
          "name" => "Text Inout",
          "transition" => "set_title",
          "type" => "text",
          "style" => @btn_style
        }
      ],
      "outputs" => [
        {"Title", "text", :title_state},
        {
          "Count",
          "text",
          :count_state
        },
        {
          "Num",
          "text",
          :num_state
        },
        {
          "Total",
          "text",
          :total_state
        }
      ],
      "transitions" => [
        {"addition", :addition},
        {"double_addition", :double_addition},
        {"subtraction", :subtraction},
        {"add_num", :add_num},
        {"reset", :reset},
        {"set_title", :set_title}
      ]
    }
  end
end
