defmodule Blake2.Blake2b do

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:blake2), 'blake2_nif')
    :erlang.load_nif(path, 0)
  end

  def blake2b_hash(input, key, inlen, keylen)
  def blake2b_hash(_, _, _, _), do: exit(:nif_library_not_loaded)

  def hash(input, key) do # input in hexadecimal for tests
    input = input |> Base.decode16! |> to_char_list
    key = to_char_list(key)
    blake2b_hash(input, key, length(input), length(key))
    |> :binary.list_to_bin
    |> Base.encode16(case: :lower)
  end

  def run_tests do
    a = hash "", ""
    b = hash "00", ""
    c = hash "0001", ""
    d = hash "000102", ""
    {a, b, c, d}
  end

end
