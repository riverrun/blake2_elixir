# blake2-elixir

Elixir implementation of the Blake2 hashing algorithm (WIP)

## Blake2

Blake2 is a modern cryptographic hash function that is fast, but at least
as secure as the latest standard SHA-3.

Blake2 comes in two flavors:

* Blake2b is optimized for 64-bit platforms
  * produces digests of any size between 1 and 64 bytes
* Blake2s is optimized for 8- to 32-bit platforms
  * produces digests of any size between 1 and 32 bytes
