defmodule Ectyl.Database.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field :first_name, :string
    field :last_name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
