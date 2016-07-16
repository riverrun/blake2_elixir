defmodule Blake2 do
  @moduledoc """
  Blake2 is a modern cryptographic hash function that is fast, but at least
  as secure as the latest standard SHA-3.

  Blake2 comes in two flavors:

    * Blake2b is optimized for 64-bit platforms
      * produces digests of any size between 1 and 64 bytes
    * Blake2s is optimized for 8- to 32-bit platforms
      * produces digests of any size between 1 and 32 bytes

  There are also the 4-way parallel Blask2bp and 8-way parallel Blake2sp
  versions.

  ## Use

  Import the appropriate module for the platform you are using. Then
  run the `hash/2` function to output the hash in bytes, or run the
  `hash_hex/2` function for hexadecimal output.

  ## Options

    * keyed hashing
    * salted hashing
    * personalized hashing
    * tree-hashing (updatable) - currently not supported.

  ## b2sum

  Currently not supported.


  """

end
