defmodule SessionStore.Mixfile do
  use Mix.Project

  def project do
    [ app: :session_store,
      version: "0.0.1",
      elixir: "~> 0.11.3-dev",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
     mod: { SessionStore, [] },
     applications: [:"elixir-resource-discovery"
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat.git" }
  defp deps do
    [
     {:"elixir-resource-discovery", ">= 0.0.1", github: "jimm/elixir-resource-discovery"},
     {:amnesia, ">= 0.1.1", github: "meh/amnesia"}
    ]
  end

  def db_create do
    Amnesia.Schema.create
  end
end
