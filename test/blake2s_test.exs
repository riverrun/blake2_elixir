defmodule Blake2sTest do
  use ExUnit.Case

  import Blake2.TestData
  alias Blake2.Blake2s

  setup_all do
    context = %{blake2s: get_data("blake2s.csv"), blake2s_keyed: get_data("blake2s_keyed.csv")}
    {:ok, context}
  end

  test "blake2s test vectors", %{blake2s: blake2s} do
    Enum.map(blake2s, fn [_, input, _, output] ->
      assert Blake2s.hash_hex(Base.decode16!(input, case: :lower), "") == output
    end)
  end

  test "blake2s keyed hash test vectors", %{blake2s_keyed: blake2s_keyed} do
    Enum.map(blake2s_keyed, fn [_, input, key, output] ->
      assert Blake2s.hash_hex(
               Base.decode16!(input, case: :lower),
               Base.decode16!(key, case: :lower)
             ) == output
    end)
  end
end
