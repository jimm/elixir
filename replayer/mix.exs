defmodule Replayer.Mixfile do
  use Mix.Project

  def project do
    [app: :replayer,
     version: "0.0.1",
     elixir: "~> 0.14.3",
     escript: escript_config,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:httpotion]]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:httpotion, github: "myfreeweb/httpotion"}]
  end

  defp escript_config do
    [main_module: Replayer.CLI]
  end
end
