defmodule StateLangWeb.Layouts.SwiftUI do
  use StateLangNative, [:layout, format: :swiftui]

  embed_templates "layouts_swiftui/*"
end
