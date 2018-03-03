defmodule ConsoleClient.Mixfile do
  use Mix.Project

  def project do
    [
      app: :console_client,
      version: "0.1.0",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dogma, "~> 0.1", only: :dev}
    ]
  end

  defp escript do
    [
      main_module: ConsoleClient,
      name: "client",
      path: "_build/escript/client"
    ]
  end
end
