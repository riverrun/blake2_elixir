defmodule Blake2bTest do
  use ExUnit.Case

  alias Blake2.Blake2b

  setup_all do
    data = Path.join([__DIR__, "testvectors", "blake2b.csv"])
            |> File.read!
            |> :binary.split("\n", [:trim, :global])
            |> Enum.map(&:binary.split(&1, ",", [:global]))
    {:ok, %{data: data}}
  end

  test "blake2b test vectors", %{data: data} do
    Enum.map data, fn [_, input, key, output] ->
      assert Blake2b.hash(Base.decode16!(input, case: :lower),
       Base.decode16!(key, case: :lower)) == output
    end
  end

end
