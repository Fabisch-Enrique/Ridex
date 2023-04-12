defmodule Ridex.Ride.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ride_requests" do
    field :lat, :float
    field :lng, :float
    field :rider_id, :id

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:lat, :lng])
    |> validate_required([:lat, :lng])
  end
end
