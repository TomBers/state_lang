defmodule StateLangWeb.HomeLive.SwiftUI do
  use StateLangNative, [:render_component, format: :swiftui]

  def render(assigns, _interface) do
    ~LVN"""
    <Text>Hello, LiveView Native!</Text>
    """
  end
end
