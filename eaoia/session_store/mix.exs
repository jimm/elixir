defmodule SessionStore.Mixfile do
  use Mix.Project

  def project do
    [ app: :session_store,
      version: "0.0.2",
      elixir: "~> 0.14.0",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ mod: { SessionStore, [] } ]
    # [ mod: { SessionStore, [] },
    #   applications: [:"elixir_resource_discovery" ] ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat.git" }
  defp deps do
    [ {:amnesia, ">= 0.1.1", github: "meh/amnesia"} ]
    # [ {:"elixir_resource_discovery", ">= 0.0.1", github: "jimm/elixir_resource_discovery"},
    #   {:amnesia, ">= 0.1.1", github: "meh/amnesia"} ]
  end
end
