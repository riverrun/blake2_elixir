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

  ## Options

  * keyed hashing - (MAC or PRF)
  * salted hashing
  * personalized hashing
  * tree-hashing (updatable)

  ## b2sum


  CURRENTLY SUPPORTED

  Blake2b and Blake2s standard and keyed hashing - tests pass

  CURRENTLY NOT SUPPORTED

  Salted hashing
  Personalized hashing
  Tree-hashing
  Parallel versions: Blask2bp, Blake2sp
  b2sum

  """



end
