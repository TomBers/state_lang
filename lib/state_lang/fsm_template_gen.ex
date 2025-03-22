defmodule FSMTemplateGenerator do
  defmacro generate_liveview(prog) do
    quote bind_quoted: [prog: prog] do
      use StateLangWeb, :live_view

      @initial_state prog.initial_state
      @module prog.module
      @transitions prog.transitions

      def mount(_params, _session, socket) do
        {:ok,
         assign(socket,
           state: @initial_state,
           module: @module,
           events: []
         )}
      end

      for {transition_name, transition_atom} <- @transitions do
        def handle_event(unquote(transition_name), params, socket) do
          state = socket.assigns.state

          new_state = apply(@module, unquote(transition_atom), [state, params])

          events = [
            "---------------",
            "Post-state: " <> Jason.encode!(new_state),
            unquote(transition_name) <> " params: " <> Jason.encode!(params),
            "Pre-state: " <> Jason.encode!(state)
          ]

          {:noreply,
           assign(socket,
             state: new_state,
             events: events ++ socket.assigns.events
           )}
        end
      end

      def render(assigns) do
        apply(@module, :render, [assigns])
      end
    end
  end
end
