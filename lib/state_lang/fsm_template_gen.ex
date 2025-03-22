defmodule FSMTemplateGenerator do
  defmacro generate_liveview(prog) do
    quote bind_quoted: [prog: prog] do
      use StateLangWeb, :live_view
      alias Phoenix.PubSub

      @initial_state prog.initial_state
      @module prog.module
      @transitions prog.transitions

      def mount(_params, _session, socket) do
        if connected?(socket) do
          PubSub.subscribe(StateLang.PubSub, "#{@module}")
        end

        {:ok,
         assign(socket,
           state: @initial_state,
           module: @module,
           events: []
         )}
      end

      for transition_name <- @transitions do
        def handle_event(unquote(transition_name), params, socket) do
          state = socket.assigns.state

          new_state =
            apply(@module, unquote(transition_name |> String.to_atom()), [state, params])

          events = [
            "---------------",
            "Post-state: " <> Jason.encode!(new_state),
            unquote(transition_name |> String.upcase()) <> " params: " <> Jason.encode!(params),
            "Pre-state: " <> Jason.encode!(state)
          ]

          {:noreply,
           assign(socket,
             state: new_state,
             events: events ++ socket.assigns.events
           )}
        end
      end

      def handle_info({:message, params}, socket) do
        new_state = apply(@module, :message_call, [socket.assigns.state, params])

        {:noreply,
         assign(socket, state: new_state, events: ["MSG RECIEVED" | socket.assigns.events])}
      end

      def render(assigns) do
        apply(@module, :render, [assigns])
      end
    end
  end
end
