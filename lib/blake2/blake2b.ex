defmodule Blake2.Blake2b do

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:blake2), 'blake2b_nif')
    :erlang.load_nif(path, 0)
  end

  def blake2b_hash(input, outlen, key)
  def blake2b_hash(_, _, _), do: exit(:nif_library_not_loaded)

  def blake2b(input \\ '', outlen \\ 32, key \\ '') do
    blake2b_hash(input, outlen, key)
    #blake2b_hash(input, outlen, key) |> Base.encode16
  end

end
