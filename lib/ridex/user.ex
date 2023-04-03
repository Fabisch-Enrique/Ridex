defmodule Ridex.User do
  alias Ridex.Repo
  alias Ridex.User

  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :phone, :string
    field :type, :string

    timestamps()
  end

  def get_or_create(phone, type) do
    case Repo.get_by(User, phone: phone, type: type) do
      nil ->
        %User{phone: phone, type: type}
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:type, :phone])
    |> validate_required([:type, :phone])
  end
end
