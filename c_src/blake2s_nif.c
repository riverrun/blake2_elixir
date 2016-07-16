#include <stdint.h>
#include <string.h>
#include <stdio.h>

#include "blake2.h"
#include "blake2-impl.h"
#include "erl_nif.h"

ERL_NIF_TERM blake2s_hash(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	blake2s_state S[1];
	ErlNifBinary input, key, salt, personal;
	uint8_t out[BLAKE2S_OUTBYTES] = {0};
	unsigned int outlen;
	int i;
	ERL_NIF_TERM hash[BLAKE2S_OUTBYTES];

	if (argc != 5 || !enif_inspect_binary(env, argv[0], &input) ||
			!enif_inspect_binary(env, argv[1], &key) ||
			!enif_get_uint(env, argv[2], &outlen) ||
			!enif_inspect_binary(env, argv[3], &salt) ||
			!enif_inspect_binary(env, argv[4], &personal))
		return enif_make_badarg(env);

	if (!outlen || outlen > BLAKE2S_OUTBYTES) return -1;
	if (key.size > BLAKE2S_KEYBYTES) return -1;

	if (key.size > 0) {
		if (blake2s_init_key(S, outlen, key.data, key.size,
					salt.data, personal.data, salt.size, personal.size) < 0) return -1;
	} else {
		if (blake2s_init(S, outlen, salt.data, personal.data,
					salt.size, personal.size) < 0) return -1;
	}

	blake2s_update(S, (const uint8_t *) input.data, (uint64_t) input.size);
	blake2s_final(S, out, outlen);

	for (i = 0; i < outlen; i++) {
		hash[i] = enif_make_uint(env, out[i]);
	}

	return enif_make_list_from_array(env, hash, outlen);
}

static int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
	return 0;
}

static ErlNifFunc blake2s_nif_funcs[] =
{
	{"hash_nif", 5, blake2s_hash}
};

ERL_NIF_INIT(Elixir.Blake2.Blake2s, blake2s_nif_funcs, NULL, NULL, upgrade, NULL)

