defmodule StateLang.States.Todo do
  @state %{"todos" => []}
  # State funcs
  def add_note(state, params), do: %{state | todos: state.todos ++ [Map.get(params, "Todo")]}
  # Output funcs
  def todo_state(state), do: Enum.join(state.todos, ", ")

  def state_machine do
    %{
      "initial_state" => @state,
      "module" => __MODULE__,
      "inputs" => [
        %{
          "name" => "Todo",
          "transition" => "add_note",
          "type" => "text"
        }
      ],
      "outputs" => [
        {
          "Todos",
          "list",
          :todo_state
        }
      ],
      "transitions" => [
        {"add_note", :add_note}
      ]
    }
  end
end
