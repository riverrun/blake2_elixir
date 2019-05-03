defmodule Blake2.TestData do
  def get_data(name) do
    Path.join([__DIR__, "testvectors", name])
    |> File.read!()
    |> :binary.split("\n", [:trim, :global])
    |> Enum.map(&:binary.split(&1, ",", [:global]))
  end
end

ExUnit.start()
