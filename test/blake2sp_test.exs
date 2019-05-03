defmodule Blake2spTest do
  use ExUnit.Case

  import Blake2.TestData
  alias Blake2.Blake2sp

  setup_all do
    context = %{
      blake2sp: get_data("blake2sp.csv"),
      blake2sp_keyed: get_data("blake2sp_keyed.csv")
    }

    {:ok, context}
  end

  test "blake2sp test vectors", %{blake2sp: blake2sp} do
    Enum.map(blake2sp, fn [_, input, _, output] ->
      assert Blake2sp.hash_hex(Base.decode16!(input, case: :lower), "") == output
    end)
  end

  test "blake2sp keyed hash test vectors", %{blake2sp_keyed: blake2sp_keyed} do
    Enum.map(blake2sp_keyed, fn [_, input, key, output] ->
      assert Blake2sp.hash_hex(
               Base.decode16!(input, case: :lower),
               Base.decode16!(key, case: :lower)
             ) == output
    end)
  end
end
