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
    forms = Map.get(prog, :forms, [])

    transition_handlers =
      Enum.map(prog.transitions, fn transition ->
        quote do
          def handle_event(unquote(transition), params, socket) do
            old_state = socket.assigns.state

            new_state =
              apply(@state_module, String.to_atom(unquote(transition)), [old_state, params])

            updated_forms =
              if old_state != new_state do
                reset_forms_for_transition(socket.assigns.forms, unquote(transition))
              else
                socket.assigns.forms
              end

            events =
              [
                "#{String.upcase(unquote(transition))}: #{inspect(params)} -> #{inspect(new_state)}"
                | socket.assigns.events
              ]
              |> Enum.take(10)

            {:noreply, assign(socket, state: new_state, events: events, forms: updated_forms)}
          end
        end
      end)

    change_handlers =
      Enum.map(forms, fn form_config ->
        form_name = Map.get(form_config, "name", Map.get(form_config, :name, "unknown"))
        change_event = "#{form_name}_change"

        quote do
          def handle_event(unquote(change_event), params, socket) do
            form_params = Map.get(params, unquote(form_name), %{})

            updated_forms =
              update_form_in_assigns(socket.assigns.forms, unquote(form_name), form_params)

            {:noreply, assign(socket, forms: updated_forms)}
          end
        end
      end)

    contents =
      quote do
        use StateLangWeb, :live_view
        alias Phoenix.PubSub

        @state_module unquote(state_module)
        @initial_state unquote(Macro.escape(prog.initial_state))
        @transitions unquote(prog.transitions)
        @timer_interval unquote(Macro.escape(Map.get(prog, :timer_interval)))
        @form_configs unquote(Macro.escape(forms))

        def mount(_params, _session, socket) do
          if @timer_interval && connected?(socket) do
            PubSub.subscribe(StateLang.PubSub, "#{@state_module}")
            :timer.send_interval(@timer_interval, self(), :tick)
          end

          # Initialize forms from state
          initial_forms = initialize_forms_from_state(@initial_state)

          {:ok,
           assign(socket,
             state: @initial_state,
             events: [],
             forms: initial_forms
           )}
        end

        # Generate transition handlers first
        unquote_splicing(transition_handlers)

        # Generate explicit form change handlers
        unquote_splicing(change_handlers)

        # Catch-all for unhandled events
        def handle_event(event_name, params, socket) do
          events =
            [
              "UNHANDLED EVENT: #{event_name} with params: #{inspect(params)}"
              | socket.assigns.events
            ]
            |> Enum.take(10)

          {:noreply, assign(socket, events: events)}
        end

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

        # Helper functions
        defp initialize_forms_from_state(state) do
          Enum.map(@form_configs, fn config ->
            form_name = get_form_name(config)
            initial_data = get_form_initial_data(config, state)

            %{
              name: form_name,
              config: config,
              form: to_form(initial_data, as: form_name)
            }
          end)
        end

        defp get_form_name(config) do
          Map.get(config, "name", Map.get(config, :name))
        end

        defp get_form_initial_data(config, state) do
          cond do
            Map.has_key?(config, "initial_data") ->
              Map.get(config, "initial_data")

            Map.has_key?(config, "data") ->
              Map.get(config, "data")

            true ->
              %{}
          end
        end

        defp update_form_in_assigns(forms, form_name, params) do
          Enum.map(forms, fn form ->
            if form.name == form_name do
              %{form | form: to_form(params, as: form_name)}
            else
              form
            end
          end)
        end

        defp get_form_by_name(forms, name) do
          Enum.find(forms, &(&1.name == name))
        end

        defp reset_forms_for_transition(forms, transition) do
          Enum.map(forms, fn form ->
            submit_event = get_submit_event(form.config)

            if submit_event == transition do
              # This form submitted to this transition, reset it
              data = get_form_data(form.config)
              %{form | form: to_form(data, as: form.name)}
            else
              form
            end
          end)
        end

        defp get_submit_event(config) do
          Map.get(config, "submit_event", Map.get(config, :submit_event))
        end

        defp get_form_data(config) do
          Map.get(config, "data", Map.get(config, :data, %{}))
        end
      end

    Module.create(live_view_module, contents, Macro.Env.location(__ENV__))
  end
end
