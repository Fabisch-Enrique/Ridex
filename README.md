# Phoenix Channels allows sending of real-time messages between senders and receivers over HTTP
# This is done through Websockets Connections
# Clients connect to a socket, much like they would with a "native" websockets server
# Phoenix uses "topics" to route messages to the right channel, and after a client connects to a socket, he can join one or many topics, and the same client can publish messages to those topics and receive updates from them.
# A topic can be any string, which we could use to broadcast a general news feed available to all users. We can also parameterize topic names.

# A Geohash is just a string that encodes/maps a geographical area in a cell. A longer geohash encodes a smaller area and vice versa.
# In our case we will name our topic the geohash, this way we can easily broadcast messages to all users connected in the same area.

# Ridex

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
