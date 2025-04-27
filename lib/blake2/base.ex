vars = [
  {Blake2.Blake2b, ~c"blake2b_nif", 64},
  {Blake2.Blake2s, ~c"blake2s_nif", 32},
  {Blake2.Blake2bp, ~c"blake2bp_nif", 64},
  {Blake2.Blake2sp, ~c"blake2sp_nif", 32}
]

for {mod, nif_file, max_out} <- vars do
  version = to_string(mod) |> String.split(".") |> List.last()
  platform = if max_out == 64, do: "64-bit", else: "8- to 32-bit"

  defmodule mod do
    @moduledoc """
    Module to hash input using the #{version} version of Blake2.

    #{version} is optimized for #{platform} platforms and
    produces digests of any size between 1 and #{max_out} bytes.

    The `hash` function produces a digest in binary form, as
    bytes. The `hash_hex` function outputs the digest in hexadecimal
    format.

    The `hash_nif` function calls the native code. It is unlikely that
    you will need to call this function directly.
    """

    @compile {:autoload, false}
    @on_load {:init, 0}

    def init do
      path = :filename.join(:code.priv_dir(:blake2_elixir), unquote(nif_file))
      :erlang.load_nif(path, 0)
    end

    def hash_nif(input, key, outlen, salt, personal)
    def hash_nif(_, _, _, _, _), do: :erlang.nif_error(:not_loaded)

    @doc """
    Main hash function - output in bytes.
    """
    def hash(input, key, outlen \\ unquote(max_out), salt \\ "", personal \\ "") do
      hash_nif(input, key, outlen, salt, personal)
      |> handle_result
    end

    @doc """
    Main hash function - output in hexadecimal format.
    """
    def hash_hex(input, key, outlen \\ unquote(max_out), salt \\ "", personal \\ "") do
      hash_nif(input, key, outlen, salt, personal)
      |> handle_result
      |> Base.encode16(case: :lower)
    end

    defp handle_result(-1), do: raise(ArgumentError, "Input error")

    defp handle_result(hash_output) do
      :binary.list_to_bin(hash_output)
    end
  end
end
