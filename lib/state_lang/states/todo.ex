defmodule StateLang.States.Todo do
  use StateLangWeb, :live_view
  use FSMTemplateGenerator

  @state %{todos: [], next_id: 1}

  # State functions
  def add_todo(state, params) do
    todo_text = get_in(params, ["todo_form", "text"]) |> String.trim()

    if todo_text != "" do
      new_todo = %{id: state.next_id, text: todo_text, completed: false}
      %{state | todos: state.todos ++ [new_todo], next_id: state.next_id + 1}
    else
      state
    end
  end

  def toggle_todo(state, %{"id" => id}) do
    todo_id = String.to_integer(id)

    %{
      state
      | todos:
          Enum.map(state.todos, fn todo ->
            if todo.id == todo_id, do: %{todo | completed: !todo.completed}, else: todo
          end)
    }
  end

  def delete_todo(state, %{"id" => id}) do
    todo_id = String.to_integer(id)
    %{state | todos: Enum.reject(state.todos, &(&1.id == todo_id))}
  end

  # Required handlers
  def message_call(state, _), do: state
  def timer(state), do: state

  # Helper functions
  def todo_stats(state) do
    completed = Enum.count(state.todos, & &1.completed)
    "#{completed}/#{length(state.todos)} completed"
  end

  def state_machine do
    %{
      initial_state: @state,
      transitions: ["add_todo", "toggle_todo", "delete_todo"],
      forms: [
        %{
          name: "todo_form",
          submit_event: "add_todo",
          data: %{"text" => ""}
        }
      ]
    }
  end

  def render(assigns) do
    ~H"""
    <div class="todo-container max-w-md mx-auto mt-8 p-6 bg-white rounded-lg shadow-lg">
      <h1 class="text-2xl font-bold mb-4">Todo List</h1>
      <div class="mb-4 text-sm text-gray-600">{todo_stats(@state)}</div>

      <%= if todo_form = Enum.find(@forms, &(&1.name == "todo_form")) do %>
        <.simple_form for={todo_form.form} phx-submit={todo_form.config[:submit_event]} class="mb-6">
          <div class="flex gap-2">
            <.input field={todo_form.form[:text]} placeholder="Add a new todo" class="flex-1" />
            <.button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
              Add
            </.button>
          </div>
        </.simple_form>
      <% end %>

      <ul class="space-y-2">
        <%= for todo <- @state.todos do %>
          <li class="flex items-center gap-3 p-3 border rounded hover:bg-gray-50">
            <button
              phx-click="toggle_todo"
              phx-value-id={todo.id}
              class={[
                "w-5 h-5 rounded border-2 flex-shrink-0",
                if(todo.completed, do: "bg-green-500 border-green-500", else: "border-gray-300")
              ]}
            >
              <%= if todo.completed do %>
                ✓
              <% else %>
                ◻
              <% end %>
            </button>
            <span class={[
              "flex-1",
              if(todo.completed, do: "line-through text-gray-500", else: "text-gray-800")
            ]}>
              {todo.text}
            </span>
            <button
              phx-click="delete_todo"
              phx-value-id={todo.id}
              class="text-red-500 hover:text-red-700"
            >
              ×
            </button>
          </li>
        <% end %>
      </ul>

      <%= if Enum.empty?(@state.todos) do %>
        <p class="text-center text-gray-500 mt-8">No todos yet!</p>
      <% end %>

      <div class="events-container">
        <h1>Events:</h1>
        <ul>
          <%= for event <- @events do %>
            <li>{event}</li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end
end
