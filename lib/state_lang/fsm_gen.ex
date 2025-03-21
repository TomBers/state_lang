defmodule FSMLiveGenerator do
  defmacro generate_liveview(prog) do
    quote bind_quoted: [prog: prog] do
      use StateLangWeb, :live_view

      @initial_state prog["initial_state"]
                     |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
                     |> Map.new()
      @module prog["module"]
      IO.inspect(@initial_state, label: "Initial state")

      @transitions prog["transitions"]

      IO.inspect(@transitions, label: "@transitions")
      @components prog["components"]
      IO.inspect(@components, label: "@components")

      def mount(_params, _session, socket) do
        {:ok, assign(socket, state: @initial_state, components: @components)}
      end

      for {transition_name, transition_atom} <- @transitions do
        def handle_event(unquote(transition_name), _params, socket) do
          state = socket.assigns.state
          # Call named function from TransitionFunctions module
          new_state = apply(@module, unquote(transition_atom), [state])
          {:noreply, assign(socket, state: new_state)}
        end
      end

      def render(var!(assigns)) do
        ~H"""
        <div>
          <p>Current Count: {@state.count}</p>
          <p>Current Num: {@state.num}</p>
          <%= for comp <- @components do %>
            <.button phx-click={comp["transition"]} class={comp["style"]}>
              {comp["name"]}
            </.button>
          <% end %>
        </div>
        """
      end
    end
  end
end
