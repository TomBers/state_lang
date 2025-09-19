defmodule StateLang.States.Todo do
  use StateLangWeb, :live_view
  use FSMTemplateGenerator

  # Remove form_data
  @state %{todos: [%{id: 1, text: "Bill", completed: false}], next_id: 2}

  # State funcs
  def add_note(state, params) do
    IO.inspect(params)
    todo_text = Map.get(params, "Todo", "") |> String.trim()

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

  # Required handlers (simplified)
  def message_call(state, _), do: state
  def timer(state), do: state

  def todo_state(state) do
    completed = Enum.count(state.todos, & &1.completed)
    "#{completed}/#{length(state.todos)} completed"
  end

  def state_machine do
    %{
      initial_state: @state,
      module: __MODULE__,
      # Remove update_form
      transitions: ["add_note", "toggle_todo", "delete_todo"],
      timer_interval: 5_000_000
    }
  end

  def render(assigns) do
    ~H"""
    <div class="todo-container max-w-md mx-auto mt-8 p-6 bg-white rounded-lg shadow-lg">
      <h1 class="text-2xl font-bold mb-4">Todo List</h1>
      <div class="mb-4 text-sm text-gray-600">{todo_state(@state)}</div>

      <.simple_form for={%{}} phx-submit="add_note" class="mb-6">
        <div class="flex gap-2">
          <.input type="text" name="Todo" placeholder="Add a new todo" class="flex-1" value="" />
          <.button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
            Add
          </.button>
        </div>
      </.simple_form>

      <ul class="space-y-2">
        <%= for todo <- @state.todos do %>
          <li class="flex items-center gap-3 p-3 border rounded hover:bg-gray-50">
            <button
              phx-click="toggle_todo"
              phx-value-id={todo.id}
              class={[
                "w-5 h-5 ",
                if(todo.completed, do: "bg-green-500", else: "bg-red-500")
              ]}
            >
              {if todo.completed do
                "✓"
              else
                "〇"
              end}
            </button>
            <span class={if(todo.completed, do: "line-through text-gray-500", else: "flex-1")}>
              {todo.text}
            </span>
            <button phx-click="delete_todo" phx-value-id={todo.id} class="text-red-500">
              ×
            </button>
          </li>
        <% end %>
      </ul>

      <%= if Enum.empty?(@state.todos) do %>
        <p class="text-center text-gray-500 mt-8">No todos yet!</p>
      <% end %>
    </div>
    """
  end
end
