defmodule Blake2.Mixfile do
  use Mix.Project

  def project do
    [app: :blake2,
     version: "0.1.0",
     elixir: "~> 1.2",
     name: "Blake2-elixir",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:elixir_make] ++ Mix.compilers,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:elixir_make, git: "https://github.com/elixir-lang/elixir_make.git"}]
    #[{:elixir_make, "~> 0.1.0"}]
  end
end
