defmodule RidexWeb.UserChannel do
  use RidexWeb, :channel

  # We need to add the missing piece: broadcast a message about the created Ride to the two users(Driver & Rider)
  # For this we implement a second channel, using one topic per User ID
  # This way, we’ll be able to push updates only to a specific user
  # So we create this second Channel (UserChannel and routemessages to it)
  def join("user:", <> user_id, _params, socket) do
    %{id: id} = socket.assigns[:current_user]

    if id == user_id do
      {:ok, socket}
    else
      {:error, :unauthorized}
    end
  end

end
