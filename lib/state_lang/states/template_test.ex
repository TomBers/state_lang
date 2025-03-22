defmodule StateLang.States.TemplateTest do
  use StateLangWeb, :live_view

  @state %{"output" => "Red", "cycles" => 0}

  # State Red -> Orange -> Green -> Red * 5 then End
  # State funcs
  def change_state(%{cycles: cycles} = state, _) when cycles >= 5, do: %{state | output: "END"}
  def change_state(%{output: "Red"} = state, _), do: %{state | output: "Orange"}
  def change_state(%{output: "Orange"} = state, _), do: %{state | output: "Green"}
  def change_state(%{output: "Green"} = state, _), do: %{output: "Red", cycles: state.cycles + 1}

  # Output funcs
  def output_state(state), do: "#{state.output} [cycles: #{state.cycles}]"

  def render(assigns) do
    ~H"""
    <div>
      <p class="output-name">Current State:</p>
      <p class="output-value">{apply(@module, :output_state, [@state])}</p>

      <.button
        phx-click="change_state"
        class="rounded-md bg-black-800 py-2 px-4 mb-4 border border-transparent text-center text-sm transition-all shadow-md hover:shadow-lg focus:bg-slate-700 focus:shadow-none active:bg-slate-700 hover:bg-slate-700 active:shadow-none disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none ml-2"
      >
        Change State
      </.button>

      <div class="events-container">
        <h1>Events:</h1>
        <ul>
          <%= for event <- @events do %>
            <li>{event}</li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def state_machine do
    %{
      "initial_state" => @state,
      "module" => __MODULE__,
      "transitions" => [
        {"change_state", :change_state}
      ]
    }
  end
end
