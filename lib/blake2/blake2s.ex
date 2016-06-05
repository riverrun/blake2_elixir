defmodule Blake2.Blake2s do
  @moduledoc """
  Blake2s is the version of Blake2 that is optimized for 8- to 32-bit platforms.
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:blake2), 'blake2s_nif')
    :erlang.load_nif(path, 0)
  end

  def blake2s_hash(input, key, outlen)
  def blake2s_hash(_, _, _), do: exit(:nif_library_not_loaded)

  def hash(input, key, outlen \\ 32) do
    blake2s_hash(input, key, outlen)
    |> :binary.list_to_bin
    |> Base.encode16(case: :lower)
  end

end
