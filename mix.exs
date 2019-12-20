defmodule Blake2.Mixfile do
  use Mix.Project

  @version "0.8.1"

  @description """
  Blake2 cryptographic hashing function for Elixir
  """

  def project do
    [
      app: :blake2_elixir,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      description: @description,
      package: package(),
      source_url: "https://github.com/riverrun/blake2_elixir",
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.5", runtime: false},
      {:ex_doc, "~> 0.20", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "c_src", "mix.exs", "Makefile*", "README.md", "LICENSE"],
      maintainers: ["David Whitlock"],
      licenses: ["BSD"],
      links: %{
        "GitHub" => "https://github.com/riverrun/blake2_elixir",
        "Docs" => "http://hexdocs.pm/blake2_elixir"
      }
    ]
  end
end
