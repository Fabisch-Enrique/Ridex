# When a client tries to connect, we will validate the JWT authentication token to make sure we can identify the connected user.
# If the token is missing or invalid, we will reject the connection, Otherwise we will store the user in the socket state using assigns map.

defmodule RidexWeb.UserSocket do
  use Phoenix.Socket

  alias Ridex.Guardian

  # routing messages to the topic pattern cell:<geohash> through the line below
  channel "cell:*", RidexWeb.CellChannel
  channel "user:*", RidexWeb.UserChannel

  def connect(%{"token" => token}, socket) do
    case Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        {:ok, assign(socket, :current_user, user)}
      _ ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(socket), do: socket.assigns[:current_user].id |> to_string()
end
