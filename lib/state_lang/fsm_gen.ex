defmodule FSMLiveGenerator do
  defmacro generate_liveview(json) do
    quote bind_quoted: [json: json] do
      use StateLangWeb, :live_view

      @initial_state json["initial_state"]
                     |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
                     |> Map.new()
      IO.inspect(@initial_state, label: "Initial state")

      @transitions json["transitions"]
      IO.inspect(@transitions, label: "@transitions")
      @components json["components"]
      IO.inspect(@components, label: "@components")

      def mount(_params, _session, socket) do
        {:ok, assign(socket, state: @initial_state, components: @components)}
      end

      for {transition_name, state_key, expression} <- @transitions do
        def handle_event(unquote(transition_name), _params, socket) do
          new_state = update_state(socket.assigns.state, unquote(state_key), unquote(expression))
          {:noreply, assign(socket, state: new_state)}
        end
      end

      def render(var!(assigns)) do
        ~H"""
        <div>
          <p>Current Count: {@state.count}</p>
          <p>Current Num: {@state.num}</p>
          <%= for comp <- @components do %>
            <button phx-click={comp["transition"]}>
              {comp["name"]}
            </button>
          <% end %>
        </div>
        """
      end

      defp update_state(state, state_key, expr) do
        binding = [state: state]
        {result, _} = Code.eval_string("state.#{state_key} #{expr}", binding)

        Map.put(state, String.to_atom(state_key), result)
      end
    end
  end
end
