vars = [{Blake2.Blake2b, 'blake2b_nif', :blake2b_hash, 64},
 {Blake2.Blake2s, 'blake2s_nif', :blake2s_hash, 32},
 {Blake2.Blake2bp, 'blake2bp_nif', :blake2bp_hash, 64},
 {Blake2.Blake2sp, 'blake2sp_nif', :blake2sp_hash, 32}]

for {mod, nif_file, hash_func, max_out} <- vars do
  version = to_string(mod) |> String.split(".") |> List.last
  platform = if max_out == 64, do: "64-bit", else: "8- to 32-bit"
  defmodule mod do
    @moduledoc """
    Module to hash input using the #{version} version of Blake2.

    #{version} is optimized for #{platform} platforms and
    produces digests of any size between 1 and #{max_out} bytes.
    """

    @compile {:autoload, false}
    @on_load {:init, 0}

    def init do
      path = :filename.join(:code.priv_dir(:blake2_elixir), unquote(nif_file))
      :erlang.load_nif(path, 0)
    end

    def unquote(hash_func)(input, key, outlen, salt, personal)
    def unquote(hash_func)(_, _, _, _, _), do: exit(:nif_library_not_loaded)

    @doc """
    Main hash function for this module.

    The `input`, `key`, `salt` and `password` should be strings.

    The `outlen` is the length, in bytes, of the hashed output, which
    will then be printed in hexadecimal format. The default value of
    `outlen` is #{max_out}, which is also the maximum value.
    """
    def hash(input, key, outlen \\ unquote(max_out), salt \\ "", personal \\ "") do
      unquote(hash_func)(input, key, outlen, salt, personal) |> handle_result
    end

    defp handle_result(-1), do: raise ArgumentError, "Input error"
    defp handle_result(hash_output) do
      :binary.list_to_bin(hash_output) |> Base.encode16(case: :lower)
    end
  end
end
