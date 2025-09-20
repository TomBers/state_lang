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

  def state_machine do
    %{
      initial_state: @state,
      transitions: ["add_todo"],
      forms: [
        %{
          name: "todo_form",
          submit_event: "add_todo",
          change_event: "todo_form_change",
          reset_data: %{"text" => ""}
        }
      ]
    }
  end

  def render(assigns) do
    ~H"""
    <h1>Basic Todo List</h1>
    <p>{display_todos(@state)}</p>
    <%= if todo_form = Enum.find(@forms, &(&1.name == "todo_form")) do %>
      <.simple_form
        for={todo_form.form}
        phx-submit={todo_form.config.submit_event}
        phx-change={todo_form.config.change_event}
      >
        <.input field={todo_form.form[:text]} placeholder="Add a new todo" class="flex-1" />
        <.button type="submit">
          Add
        </.button>
      </.simple_form>
    <% end %>
    """
  end
end
