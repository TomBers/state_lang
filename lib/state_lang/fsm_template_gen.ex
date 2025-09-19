defmodule FSMTemplateGenerator do
  defmacro __using__(_opts) do
    quote do
      @after_compile FSMTemplateGenerator
    end
  end

  def __after_compile__(env, _) do
    # Convert StateLang.States.TemplateTest -> StateLangWeb.TemplateTestLive
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

        @initial_state unquote(Macro.escape(prog.initial_state))
        @module unquote(prog.module)
        @transitions unquote(prog.transitions)
        @timer_interval unquote(prog.timer_interval)

        def mount(_params, _session, socket) do
          if connected?(socket) do
            # TOD0 Check if timer_interval set
            if @timer_interval do
              PubSub.subscribe(StateLang.PubSub, "#{@module}")
              :timer.send_interval(@timer_interval, self(), :tick)
            end
          end

          {:ok,
           assign(socket,
             state: @initial_state,
             module: @module,
             events: []
           )}
        end

        for transition_name <- @transitions do
          def handle_event(transition_name, params, socket) do
            state = socket.assigns.state

            new_state =
              apply(@module, transition_name |> String.to_atom(), [state, params])

            events = [
              "---------------",
              "Post-state: " <> Jason.encode!(new_state),
              String.upcase(transition_name) <> " params: " <> Jason.encode!(params),
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

          events = [
            "---------------",
            "Post-state: " <> Jason.encode!(new_state),
            "MSG RECEIVED params: " <> Jason.encode!(params),
            "Pre-state: " <> Jason.encode!(socket.assigns.state)
          ]

          {:noreply, assign(socket, state: new_state, events: events ++ socket.assigns.events)}
        end

        def handle_info(:tick, socket) do
          new_state = apply(@module, :timer, [socket.assigns.state])
          {:noreply, assign(socket, state: new_state)}
        end

        def render(assigns) do
          apply(@module, :render, [assigns])
        end
      end

    Module.create(live_view_module, contents, Macro.Env.location(__ENV__))
  end
end
