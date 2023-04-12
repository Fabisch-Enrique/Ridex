defmodule RidexWeb.CellChannel do
  use RidexWeb, :channel

  alias Ridex.{Repo, Ride}

  intercept ["ride:requested"]

  # for now, our join doesn't do anything because Phoenix manages state of clients connected to a specific channel for us.
  def join("cell:" <> _geohash, _params, socket) do
    {:ok, %{}, socket}
  end


  def handle_in("ride:request", %{"position" => position}, socket) do
    case Ridex.RideRequest.create(socket.assigns[:current_user], position) do
      {:ok, request} ->
        broadcast! socket, "ride:requested", %{request_id: request.id, position: position}
        {:reply, :ok, socket}
      {:error, _changeset} ->
        {:reply, {:error, :insert_error}, socket}
    end
  end


  def handle_in("ride:accept_request", %{"request_id" => request_id}, socket) do

    # We can first check the existence of the Ride request by the given ID.
    case Repo.get(Ridex.RideRequest, request_id) do
      nil ->
        {:reply, :error, socket}
      request ->
        case Ride.create(request.rider_id, socket.assigns[:current_user].id, request.position) do
          {:ok, ride} ->
            
            # broadcast to both the drive and the rider about the created ride
            RidexWeb.Endpoint.broadcast("user:#{ride.driver_id}", "ride:created", %{ride_id: ride.id})
            RidexWeb.Endpoint.broadcast("user:#{ride.rider_id}", "ride:created", %{ride_id: ride.id})
            {:reply, :ok, socket}
          {:error, _changeset} ->
            {:reply, :error, socket}
        end
    end
  end


  # Drivers are the only ones who are supposed to receive the "ride:requested message", therefor,
  # we implement the handle_out callback to "intercept outgoing messages", to send them only to Drivers.
  def handle_out("ride:requested", payload, socket) do
    if socket.assigns[:current_user].type == "driver" do
      push(socket, "ride:requested", payload)
    end

    {:noreply, socket}
  end
end
