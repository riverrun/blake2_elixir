defmodule Blake2.LoadNIFS do
  @moduledoc """
  Create modules to load the functions from each of the NIF
  files.
  """

  vars = [{Blake2.Blake2b, 'blake2b_nif', :blake2b_hash},
   {Blake2.Blake2s, 'blake2s_nif', :blake2s_hash}]

  for {mod, nif_file, hash_func} <- vars do
    defmodule mod do
      @compile {:autoload, false}
      @on_load {:init, 0}

      def init do
        path = :filename.join(:code.priv_dir(:blake2_elixir), unquote(nif_file))
        :erlang.load_nif(path, 0)
      end

      def unquote(hash_func)(input, key, outlen, salt, personal)
      def unquote(hash_func)(_, _, _, _, _), do: exit(:nif_library_not_loaded)
    end
  end
end
