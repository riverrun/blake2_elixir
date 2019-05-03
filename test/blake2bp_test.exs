defmodule Blake2bpTest do
  use ExUnit.Case

  import Blake2.TestData
  alias Blake2.Blake2bp

  setup_all do
    context = %{
      blake2bp: get_data("blake2bp.csv"),
      blake2bp_keyed: get_data("blake2bp_keyed.csv")
    }

    {:ok, context}
  end

  test "blake2bp test vectors", %{blake2bp: blake2bp} do
    Enum.map(blake2bp, fn [_, input, _, output] ->
      assert Blake2bp.hash_hex(Base.decode16!(input, case: :lower), "") == output
    end)
  end

  test "blake2bp keyed hash test vectors", %{blake2bp_keyed: blake2bp_keyed} do
    Enum.map(blake2bp_keyed, fn [_, input, key, output] ->
      assert Blake2bp.hash_hex(
               Base.decode16!(input, case: :lower),
               Base.decode16!(key, case: :lower)
             ) == output
    end)
  end
end
