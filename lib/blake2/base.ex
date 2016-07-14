vars = [{Blake2.Blake2b, 'blake2b_nif', :blake2b_hash, 64},
 {Blake2.Blake2s, 'blake2s_nif', :blake2s_hash, 32}]

for {mod, nif_file, hash_func, outlength} <- vars do
  defmodule mod do
    @compile {:autoload, false}
    @on_load {:init, 0}

    def init do
      path = :filename.join(:code.priv_dir(:blake2_elixir), unquote(nif_file))
      :erlang.load_nif(path, 0)
    end

    def unquote(hash_func)(input, key, outlen, salt, personal)
    def unquote(hash_func)(_, _, _, _, _), do: exit(:nif_library_not_loaded)

    def hash(input, key, outlen \\ unquote(outlength), salt \\ "", personal \\ "") do
      unquote(hash_func)(input, key, outlen, salt, personal) |> handle_result
    end

    defp handle_result(-1), do: raise ArgumentError, "Input error"
    defp handle_result(hash_output) do
      :binary.list_to_bin(hash_output) |> Base.encode16(case: :lower)
    end
  end
end
