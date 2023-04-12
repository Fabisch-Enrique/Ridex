defmodule RidexWeb.CellChannelTest do
  use RidexWeb.ChannelCase, async: true

  alias Ridex.{User, Repo, Ride}
  alias RidexWeb.{UserSocket, CellChannel}

  # we creating a new Rider and connected him/her to his/her socket using the socket helper.
  # We then called subscribe_and_join by passing the channel module and the topic to join.

  setup do
    {:ok, rider} = User.get_or_create("+254792874627", "rider")
    {:ok, rider} = User.get_or_create("+254701161418", "driver")

    {:ok, _, rider_socket} =
      UserSocket
      |> socket(rider.id, %{current_user: rider})
      |> subscribe_and_join(CellChannel, "cell:xyz")

      {:ok, _, rider_socket} =
        UserSocket
        |> socket(driver.id, %{current_user: driver})
        |> subscribe_and_join(CellChannel, "cell:xyz")

      %{
        rider_socket: rider_socket,
        driver: driver_socket,
        rider: rider,
        driver: driver
      }
  end

  test "broadcasts ride:created to both users", %{driver_socket: driver_socket, rider: rider, driver:driver} do
    Phoenix.PubSub.subscribe(Ridex.PubSub, "user:#{rider.id}")
    Phoenix.PubSub.subscribe(Ridex.PubSub, "user:#{driver.id}")
    position = %{"lat" => 51.36577, "lng" => 0.6476747}
    {:ok, request} = Ridex.RideRequest.create(rider, position)

    ref = push(driver_socket, "rider:accept_request", %{request_id: request.id})
    assert_reply ref, :ok, %{}

    [%{id: ride_id}] = Ride |> Repo.all()

    assert_receive %Phoenix.Socket.Broadcast{event: "ride:created", payload: %{ride_id: ride_id}}
    
    assert_receive %Phoenix.Socket.Broadcast{event: "ride:created", payload: %{ride_id: ride_id}}
  end


  test "accepts ride request and creates ride", %{driver_socket: driver_socket, rider: rider, driver: driver} do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}
    {:ok, request} = Ridex.RideRequest.create(rider, position)

    ref = push(driver_socket, "rider:accept_request", %{request_id: request.id})
    assert_reply ref, :ok, %{}

    assert [ride] = Ride |> Repo.all()
    assert ride.driver_id == driver.id
    assert ride.rider_id == rider.id
  end

  test "fail to accept non existing ride request", %{driver_socket: driver_socket} do
    ref = push(driver_socket, "ride:accept_request", %{request_id: 123})
    assert_reply ref, :error, %{}

    assert [] = Ride |> Repo.all()
  end


# In the tests cases, we used the helper functions push, assert_reply and assert_broadcasted,
# to push messages and assert the expected behavior

  test "creates a ride request", %{rider_socket: rider_socket} do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}

    ref = push(rider_socket, "rider:request", %{position: position})
    assert_reply ref, :ok, %{}

    [request] = Ridex.RideRequest |> Repo.all()

    assert request.lat == position["lat"]
    assert request.lng == position["lng"]
  end


  test "broadcast ride request message", %{rider_socket: rider_socket} do
    position = position = %{"lat" => 51.36577, "lng" => 0.6476747}

    ref = push(rider_socket, "rider:request", %{position: position})
    assert_reply ref, :ok, %{}

    [%{id: request_id}] = Ridex.RideRequest |> Repo.all()

    assert_broadcast("ride:requested", %{request_id: request_id, position: position})
  end
end
