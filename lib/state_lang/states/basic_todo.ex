defmodule StateLang.States.BasicTodo do
  use StateLangWeb, :live_view
  use FSMTemplateGenerator

  @state %{todos: []}

  def add_todo(state, %{"todo_form" => %{"text" => text}}) do
    %{state | todos: [text | state.todos]}
  end

  def display_todos(state) do
    state.todos |> Enum.join(",")
  end

  def todo_form do
    %{
      name: "todo_form",
      submit_event: "add_todo",
      data: %{"text" => ""}
    }
  end

  def state_machine do
    %{
      initial_state: @state,
      transitions: ["add_todo"],
      forms: [todo_form()]
    }
  end
end
