defmodule Blake2.Blake2b do

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:blake2), 'blake2_nif')
    :erlang.load_nif(path, 0)
  end

  def blake2b_hash(input, key, outlen)
  def blake2b_hash(_, _, _), do: exit(:nif_library_not_loaded)

  def hash(input, key, outlen \\ 64) do
    blake2b_hash(input, key, outlen)
    |> :binary.list_to_bin
    |> Base.encode16(case: :lower)
  end

  def run_tests do
    a = "" |> Base.decode16! |> hash("")
    b = "00" |> Base.decode16! |> hash("")
    c = "0001" |> Base.decode16! |> hash("")
    d = "000102" |> Base.decode16! |> hash("")
    {a, b, c, d}
  end

end
