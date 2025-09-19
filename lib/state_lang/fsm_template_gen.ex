defmodule FSMTemplateGenerator do
  defmacro __using__(_opts) do
    quote do
      @after_compile FSMTemplateGenerator
    end
  end

  def __after_compile__(env, _) do
    live_view_module = state_to_live_module(env.module)
    generate_liveview_module(live_view_module, env.module)
  end

  def state_to_live_module(state_module) do
    state_module
    |> Atom.to_string()
    |> String.replace("StateLang.States.", "StateLangWeb.")
    |> Kernel.<>("Live")
    |> String.to_atom()
  end

  def generate_liveview_module(live_view_module, state_module) do
    prog = apply(state_module, :state_machine, [])

    contents =
      quote do
        use StateLangWeb, :live_view
        alias Phoenix.PubSub

        @state_module unquote(state_module)
        @initial_state unquote(Macro.escape(prog.initial_state))
        @transitions unquote(prog.transitions)
        @timer_interval unquote(prog.timer_interval)

        def mount(_params, _session, socket) do
          if connected?(socket) do
            PubSub.subscribe(StateLang.PubSub, "#{@state_module}")
            :timer.send_interval(@timer_interval, self(), :tick)
          end

          {:ok, assign(socket, state: @initial_state, events: [])}
        end

        # Generate all transition handlers dynamically
        for transition <- @transitions do
          def handle_event(transition, params, socket) do
            new_state =
              apply(@state_module, String.to_atom(transition), [
                socket.assigns.state,
                params
              ])

            events =
              [
                "#{String.upcase(transition)}: #{Jason.encode!(params)} -> #{Jason.encode!(new_state)}"
                | socket.assigns.events
              ]
              # Keep only last 10 events
              |> Enum.take(10)

            {:noreply, assign(socket, state: new_state, events: events)}
          end
        end

        # Simplified message and timer handlers
        def handle_info({:message, params}, socket) do
          new_state = apply(@state_module, :message_call, [socket.assigns.state, params])
          {:noreply, assign(socket, state: new_state)}
        end

        def handle_info(:tick, socket) do
          new_state = apply(@state_module, :timer, [socket.assigns.state])
          {:noreply, assign(socket, state: new_state)}
        end

        def render(assigns) do
          apply(@state_module, :render, [assigns])
        end
      end

    Module.create(live_view_module, contents, Macro.Env.location(__ENV__))
  end
end
