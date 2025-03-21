defmodule FSMLiveGenerator do
  defmacro generate_liveview(prog) do
    quote bind_quoted: [prog: prog] do
      use StateLangWeb, :live_view

      @initial_state prog["initial_state"]
                     |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
                     |> Map.new()
      @module prog["module"]
      @transitions prog["transitions"]
      @inputs prog["inputs"]
      @outputs prog["outputs"]

      def mount(_params, _session, socket) do
        {:ok,
         assign(socket,
           state: @initial_state,
           inputs: @inputs,
           outputs: @outputs,
           module: @module
         )}
      end

      for {transition_name, transition_atom} <- @transitions do
        def handle_event(unquote(transition_name), params, socket) do
          IO.inspect(params, label: "Params")
          state = socket.assigns.state

          new_state = apply(@module, unquote(transition_atom), [state, params])
          {:noreply, assign(socket, state: new_state)}
        end
      end

      def render(var!(assigns)) do
        ~H"""
        <div>
          <%= for {name, _type, state_fn} <- @outputs do %>
            <p>{name}</p>
            <p>{apply(@module, state_fn, [@state])}</p>
          <% end %>
          <%= for comp <- @inputs do %>
            <%= case comp["type"] do %>
              <% "text" -> %>
                <.simple_form for={%{}} phx-submit={comp["transition"]}>
                  <.input
                    type="text"
                    name={comp["name"]}
                    class={comp["style"]}
                    value={@state[comp["name"]]}
                    placeholder={comp["name"]}
                  >
                  </.input>
                </.simple_form>
              <% _ -> %>
                <.button phx-click={comp["transition"]} class={comp["style"]}>
                  {comp["name"]}
                </.button>
            <% end %>
          <% end %>
        </div>
        """
      end
    end
  end
end
