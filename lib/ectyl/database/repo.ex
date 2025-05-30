defmodule Ectyl.Database.Repo do
  use Ecto.Repo,
    otp_app: :ectyl,
    adapter: Ecto.Adapters.Postgres
end
