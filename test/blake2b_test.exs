defmodule Blake2bTest do
  use ExUnit.Case

  alias Blake2.Blake2b

  setup_all do
    blake2b = get_data "blake2b.csv"
    blake2b_keyed = get_data "blake2b_keyed.csv"
    {:ok, %{blake2b: blake2b, blake2b_keyed: blake2b_keyed}}
  end

  def get_data(name) do
    Path.join([__DIR__, "testvectors", name])
    |> File.read!
    |> :binary.split("\n", [:trim, :global])
    |> Enum.map(&:binary.split(&1, ",", [:global]))
  end

  test "blake2b test vectors", %{blake2b: blake2b} do
    Enum.map blake2b, fn [_, input, _, output] ->
      assert Blake2b.hash(Base.decode16!(input, case: :lower), "") == output
    end
  end

  test "blake2b keyed hash test vectors", %{blake2b_keyed: blake2b_keyed} do
    Enum.map blake2b_keyed, fn [_, input, key, output] ->
      assert Blake2b.hash(Base.decode16!(input, case: :lower),
       Base.decode16!(key, case: :lower)) == output
    end
  end

end
