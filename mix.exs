defmodule Steno.Mixfile do
  use Mix.Project

  def project do
    [app: :steno,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Steno.Application, []},
     extra_applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0-rc"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.2"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:porcelain, "~> 2.0"},
     {:gproc, "~> 0.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:ex_machina, "~> 2.0", only: [:dev, :test]},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"],
     "deps.get": [&get_goon/1, "deps.get"],
    ]
  end

  defp get_goon(_) do
    unless File.exists?("goon") do
      goon_url = "https://github.com/alco/goon/releases/download/v1.1.1/goon_linux_amd64.tar.gz"
      System.cmd("bash", ["-c", "wget -O /tmp/goon.tar.gz #{goon_url}"])
      System.cmd("bash", ["-c", "(cd /tmp && tar xzf goon.tar.gz)"])
      System.cmd("bash", ["-c", "cp /tmp/goon ."])
    end
  end
end
