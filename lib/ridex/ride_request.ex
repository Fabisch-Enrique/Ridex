defmodule Ridex.RideRequest do
  alias Ridex.Repo

  def create(rider, %{"lat" => lat, "lng" => lng}) do
    %Ridex.Ride{
      rider_id: rider.id, lat: lat, lng: lng
    }
    |> Repo.insert()
  end
end
