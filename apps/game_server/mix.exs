defmodule GameServer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :game_server,
      version: "0.1.0",
      build_path: "_build",
      config_path: "../../config/config.exs",
      deps_path: "deps",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {GameServer.Application, []}
    ]
  end

  defp deps do
    [
      {:message, in_umbrella: true},
      {:httpoison, "~> 1.0.0"},
      {:poison, "~> 3.1.0"},
      {:distillery, "~> 1.5", runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dogma, "~> 0.1", only: :dev}
    ]
  end
end
