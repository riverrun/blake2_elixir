defmodule Blake2.Blake2b do
  @moduledoc """
  Blake2b is the version of Blake2 that is optimized for 64-bit platforms.
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:blake2), 'blake2b_nif')
    :erlang.load_nif(path, 0)
  end

  def blake2b_hash(input, key, outlen, salt, personal)
  def blake2b_hash(_, _, _, _, _), do: exit(:nif_library_not_loaded)

  def hash(input, key, outlen \\ 64, salt \\ "", personal \\ "") do
    blake2b_hash(input, key, outlen, salt, personal)
    |> :binary.list_to_bin
    |> Base.encode16(case: :lower)
  end

end
