defmodule StateLang.States.Todo do
  use StateLangWeb, :live_view
  use FSMTemplateGenerator

  @state %{todos: [], next_id: 1, form_data: %{"Todo" => ""}}

  def update_form(state, params) do
    %{state | form_data: params}
  end

  # State funcs
  def add_note(state, params) do
    todo_text = Map.get(params, "Todo", "") |> String.trim()

    if todo_text != "" do
      new_todo = %{id: state.next_id, text: todo_text, completed: false}

      %{
        state
        | todos: state.todos ++ [new_todo],
          next_id: state.next_id + 1,
          form_data: %{"Todo" => ""}
      }
    else
      # Don't add empty todos
      state
    end
  end

  def toggle_todo(state, %{"id" => id}) do
    todo_id = String.to_integer(id)

    updated_todos =
      Enum.map(state.todos, fn todo ->
        if todo.id == todo_id do
          %{todo | completed: !todo.completed}
        else
          todo
        end
      end)

    %{state | todos: updated_todos}
  end

  def delete_todo(state, %{"id" => id}) do
    todo_id = String.to_integer(id)
    updated_todos = Enum.reject(state.todos, &(&1.id == todo_id))
    %{state | todos: updated_todos}
  end

  # Message and timer handlers
  def message_call(state, _), do: state
  def timer(state), do: state

  # Output funcs
  def todo_state(state) do
    completed = Enum.count(state.todos, & &1.completed)
    total = length(state.todos)
    "#{completed}/#{total} completed"
  end

  def state_machine do
    %{
      initial_state: @state,
      # Fixed: was **MODULE**
      module: __MODULE__,
      transitions: [
        "add_note",
        "toggle_todo",
        "delete_todo",
        "update_form"
      ],
      timer_interval: 5_000_000
    }
  end

  def render(assigns) do
    ~H"""
    <div class="todo-container max-w-md mx-auto mt-8 p-6 bg-white rounded-lg shadow-lg">
      <h1 class="text-2xl font-bold mb-4 text-gray-800">Todo List</h1>

      <div class="mb-4 text-sm text-gray-600">
        {todo_state(@state)}
      </div>

      <.simple_form
        for={to_form(@state.form_data)}
        phx-submit="add_note"
        phx-change="update_form"
        class="mb-6"
      >
        <div class="flex gap-2">
          <.input
            type="text"
            field={to_form(@state.form_data)["Todo"]}
            placeholder="Add a new todo"
            class="flex-1"
          />
          <.button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
            Add
          </.button>
        </div>
      </.simple_form>

      <ul class="space-y-2">
        <%= for todo <- @state.todos do %>
          <li class="flex items-center gap-3 p-3 border rounded-lg hover:bg-gray-50">
            <.button
              phx-click="toggle_todo"
              phx-value-id={todo.id}
              class={[
                "w-5 h-5 rounded border-2 flex-shrink-0",
                if(todo.completed,
                  do: "bg-green-500 border-green-500",
                  else: "border-gray-300 hover:border-gray-400"
                )
              ]}
            >
              <%= if todo.completed do %>
                <svg class="w-3 h-3 text-white mx-auto" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" />
                </svg>
              <% end %>
            </.button>

            <span class={[
              "flex-1",
              if(todo.completed, do: "line-through text-gray-500", else: "text-gray-800")
            ]}>
              {todo.text}
            </span>

            <.button
              phx-click="delete_todo"
              phx-value-id={todo.id}
              class="text-red-500 hover:text-red-700 p-1"
            >
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z" />
                <path
                  fill-rule="evenodd"
                  d="M4 5a2 2 0 012-2h8a2 2 0 012 2v6a2 2 0 01-2 2H6a2 2 0 01-2-2V5zm3 4a1 1 0 112 0v1a1 1 0 11-2 0V9zm4 0a1 1 0 112 0v1a1 1 0 11-2 0V9z"
                  clip-rule="evenodd"
                />
              </svg>
            </.button>
          </li>
        <% end %>
      </ul>

      <%= if Enum.empty?(@state.todos) do %>
        <div class="text-center text-gray-500 mt-8">
          <svg class="w-12 h-12 mx-auto mb-4 text-gray-300" fill="currentColor" viewBox="0 0 20 20">
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <p>No todos yet. Add one above!</p>
        </div>
      <% end %>
    </div>
    """
  end
end
