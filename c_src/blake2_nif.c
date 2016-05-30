#include <stdint.h>
#include <string.h>
#include <stdio.h>

#include "erl_nif.h"
#include "blake2.h"

ERL_NIF_TERM blake2b_hash(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	uint8_t out[64] = {0};
	char input[256];
	char key[64] = {0};
	unsigned int inlen, keylen;
	int i;
	ERL_NIF_TERM hash[64];

	if (!enif_get_string(env, argv[0], input, sizeof(input), ERL_NIF_LATIN1) ||
			!enif_get_string(env, argv[1], key, sizeof(key), ERL_NIF_LATIN1) ||
			!enif_get_uint(env, argv[2], &inlen) ||
			!enif_get_uint(env, argv[3], &keylen))
		return enif_make_badarg(env);

	blake2b(out, input, key, BLAKE2B_OUTBYTES, (uint64_t) inlen, keylen);
	for (i = 0; i < BLAKE2B_OUTBYTES; i++) {
		hash[i] = enif_make_uint(env, out[i]);
	}
	return enif_make_list_from_array(env, hash, BLAKE2B_OUTBYTES);
}

static int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
	return 0;
}

static ErlNifFunc blake2b_nif_funcs[] =
{
	{"blake2b_hash", 4, blake2b_hash}
};

ERL_NIF_INIT(Elixir.Blake2.Blake2b, blake2b_nif_funcs, NULL, NULL, upgrade, NULL)
