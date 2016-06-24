defmodule Blake2.Blake2b do
  @moduledoc """
  Blake2b is the version of Blake2 that is optimized for 64-bit platforms.
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:blake2_elixir), 'blake2b_nif')
    :erlang.load_nif(path, 0)
  end

  def blake2b_hash(input, key, outlen, salt, personal)
  def blake2b_hash(_, _, _, _, _), do: exit(:nif_library_not_loaded)

  def hash(input, key, outlen \\ 64, salt \\ "", personal \\ "") do
    blake2b_hash(input, key, outlen, salt, personal) |> handle_result
  end

  defp handle_result(-1), do: raise ArgumentError, "Something went wrong!"
  defp handle_result(hash_output) do
    :binary.list_to_bin(hash_output) |> Base.encode16(case: :lower)
  end
end
