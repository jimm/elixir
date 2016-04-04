defmodule CoreMIDI.Mixfile do
  use Mix.Project

  def project do
    [app: :core_midi,
     version: "0.0.1",
     elixir: "~> 1.1-dev",
     compilers: [:make, :elixir, :app],
     aliases: aliases,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :core_midi]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    []
  end

  defp aliases do
    [clean: ["clean", "clean.make"]]
  end
end

###################
# Make file Tasks #
###################
 
defmodule Mix.Tasks.Compile.Make do
  @shortdoc "Compiles helper in c_src"
 
  def run(_) do
    File.cd("c_src")
    {result, _error_code} = System.cmd("make", [], stderr_to_stdout: true)
    File.cd("..")
    Mix.shell.info result
    :ok
  end
end
 
defmodule Mix.Tasks.Clean.Make do
  @shortdoc "Cleans helper in c_src"
 
  def run(_) do
    File.cd("c_src")
    {result, _error_code} = System.cmd("make", ['clean'], stderr_to_stdout: true)
    File.cd("..")
    Mix.shell.info result
    :ok
  end
end
