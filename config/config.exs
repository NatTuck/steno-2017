# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :steno,
  ecto_repos: [Steno.Repo]

# Configures the endpoint
config :steno, Steno.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "c1ousQDspOFBqSgL6f7GBIkqREX+SldWD853h9ENXud5PfUVL+JVergCwN6H5P87",
  render_errors: [view: Steno.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Steno.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Config for Porcelain / Goon
config :porcelain, :driver, Porcelain.Driver.Goon

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
