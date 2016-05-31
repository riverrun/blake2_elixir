#include <stdint.h>
#include <stdio.h>

#include "erl_nif.h"
#include "blake2.h"

ERL_NIF_TERM blake2b_hash(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary input, key;
	uint8_t out[64] = {0};
	unsigned int outlen;
	int i;
	ERL_NIF_TERM hash[64];

	if (argc != 3 || !enif_inspect_binary(env, argv[0], &input) ||
			!enif_inspect_binary(env, argv[1], &key) ||
			!enif_get_uint(env, argv[2], &outlen))
		return enif_make_badarg(env);

	blake2b(out, input.data, key.data, outlen, (uint64_t) input.size, key.size);
	for (i = 0; i < outlen; i++) {
		hash[i] = enif_make_uint(env, out[i]);
	}
	return enif_make_list_from_array(env, hash, outlen);
}

static int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
	return 0;
}

static ErlNifFunc blake2b_nif_funcs[] =
{
	{"blake2b_hash", 3, blake2b_hash}
};

ERL_NIF_INIT(Elixir.Blake2.Blake2b, blake2b_nif_funcs, NULL, NULL, upgrade, NULL)
