defmodule StateLang.Repo do
  use Ecto.Repo,
    otp_app: :state_lang,
    adapter: Ecto.Adapters.Postgres
end
