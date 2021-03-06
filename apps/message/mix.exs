defmodule Message.Mixfile do
  use Mix.Project

  def project do
    [
      app: :message,
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
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1.0"}
    ]
  end
end
