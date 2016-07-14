/*
   BLAKE2 reference source code package - reference C implementations

   Copyright 2012, Samuel Neves <sneves@dei.uc.pt>.  You may use this under the
   terms of the CC0, the OpenSSL Licence, or the Apache Public License 2.0, at
   your option.  The terms of these licenses can be found at:

   - CC0 1.0 Universal : http://creativecommons.org/publicdomain/zero/1.0
   - OpenSSL license   : https://www.openssl.org/source/license.html
   - Apache 2.0        : http://www.apache.org/licenses/LICENSE-2.0

   More information about the BLAKE2 hash function can be found at
   https://blake2.net.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#if defined(_OPENMP)
#include <omp.h>
#endif

#include "blake2.h"
#include "blake2-impl.h"
#include "erl_nif.h"

#define PARALLELISM_DEGREE 4

static inline int blake2bp_init_leaf( blake2b_state *S, uint8_t outlen, uint8_t keylen, uint64_t offset,
		const void *salt, const void *personal, const uint8_t saltlen, const uint8_t personallen )
{
	blake2b_param P[1];
	P->digest_length = outlen;
	P->key_length = keylen;
	P->fanout = PARALLELISM_DEGREE;
	P->depth = 2;
	store32( &P->leaf_length, 0 );
	store64( &P->node_offset, offset );
	P->node_depth = 0;
	P->inner_length = BLAKE2B_OUTBYTES;
	memset( P->reserved, 0, sizeof( P->reserved ) );
	//memset( P->salt, 0, sizeof( P->salt ) );
	//memset( P->personal, 0, sizeof( P->personal ) );
	if (saltlen) {
		memcpy( P->salt, salt, BLAKE2B_SALTBYTES );
	} else {
		memset(P->salt, 0, sizeof( P->salt ));
	}
	if (personallen) {
		memcpy( P->personal, personal, BLAKE2B_PERSONALBYTES );
	} else {
		memset(P->personal, 0, sizeof(P->personal));
	}
	return blake2b_init_param( S, P );
}

static inline int blake2bp_init_root( blake2b_state *S, uint8_t outlen, uint8_t keylen,
		const void *salt, const void *personal, const uint8_t saltlen, const uint8_t personallen )
{
	blake2b_param P[1];
	P->digest_length = outlen;
	P->key_length = keylen;
	P->fanout = PARALLELISM_DEGREE;
	P->depth = 2;
	store32( &P->leaf_length, 0 );
	store64( &P->node_offset, 0 );
	P->node_depth = 1;
	P->inner_length = BLAKE2B_OUTBYTES;
	memset( P->reserved, 0, sizeof( P->reserved ) );
	//memset( P->salt, 0, sizeof( P->salt ) );
	//memset( P->personal, 0, sizeof( P->personal ) );
	if (saltlen) {
		memcpy( P->salt, salt, BLAKE2B_SALTBYTES );
	} else {
		memset(P->salt, 0, sizeof( P->salt ));
	}
	if (personallen) {
		memcpy( P->personal, personal, BLAKE2B_PERSONALBYTES );
	} else {
		memset(P->personal, 0, sizeof(P->personal));
	}
	return blake2b_init_param( S, P );
}

ERL_NIF_TERM blake2bp_hash(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	uint8_t hash[PARALLELISM_DEGREE][BLAKE2B_OUTBYTES];
	blake2b_state S[PARALLELISM_DEGREE][1];
	blake2b_state FS[1];
	ErlNifBinary input, key, salt, personal;
	uint8_t out[BLAKE2B_OUTBYTES] = {0};
	unsigned int outlen;
	int i;
	ERL_NIF_TERM tmphash[BLAKE2B_OUTBYTES];

	if (argc != 5 || !enif_inspect_binary(env, argv[0], &input) ||
			!enif_inspect_binary(env, argv[1], &key) ||
			!enif_get_uint(env, argv[2], &outlen) ||
			!enif_inspect_binary(env, argv[3], &salt) ||
			!enif_inspect_binary(env, argv[4], &personal))
		return enif_make_badarg(env);

	if (!outlen || outlen > BLAKE2B_OUTBYTES) return -1;
	if( key.size > BLAKE2B_KEYBYTES ) return -1;

	for( size_t i = 0; i < PARALLELISM_DEGREE; ++i )
		if( blake2bp_init_leaf( S[i], outlen, key.size, i, salt.data,
					personal.data, salt.size, personal.size) < 0 )
			return -1;

	S[PARALLELISM_DEGREE - 1]->last_node = 1; // mark last node

	if( key.size > 0 )
	{
		uint8_t block[BLAKE2B_BLOCKBYTES];
		memset( block, 0, BLAKE2B_BLOCKBYTES );
		memcpy( block, key.data, key.size );

		for( size_t i = 0; i < PARALLELISM_DEGREE; ++i )
			blake2b_update( S[i], block, BLAKE2B_BLOCKBYTES );

		secure_zero_memory( block, BLAKE2B_BLOCKBYTES ); /* Burn the key from stack */
	}

#if defined(_OPENMP)
#pragma omp parallel shared(S,hash), num_threads(PARALLELISM_DEGREE)
#else

	for( size_t id__ = 0; id__ < PARALLELISM_DEGREE; ++id__ )
#endif
	{
#if defined(_OPENMP)
		size_t      id__ = omp_get_thread_num();
#endif
		uint64_t inlen__ = input.size;
		const uint8_t *in__ = ( const uint8_t * )input.data;
		in__ += id__ * BLAKE2B_BLOCKBYTES;

		while( inlen__ >= PARALLELISM_DEGREE * BLAKE2B_BLOCKBYTES )
		{
			blake2b_update( S[id__], in__, BLAKE2B_BLOCKBYTES );
			in__ += PARALLELISM_DEGREE * BLAKE2B_BLOCKBYTES;
			inlen__ -= PARALLELISM_DEGREE * BLAKE2B_BLOCKBYTES;
		}

		if( inlen__ > id__ * BLAKE2B_BLOCKBYTES )
		{
			const size_t left = inlen__ - id__ * BLAKE2B_BLOCKBYTES;
			const size_t len = left <= BLAKE2B_BLOCKBYTES ? left : BLAKE2B_BLOCKBYTES;
			blake2b_update( S[id__], in__, len );
		}

		blake2b_final( S[id__], hash[id__], BLAKE2B_OUTBYTES );
	}

	if( blake2bp_init_root( FS, outlen, key.size, salt.data, personal.data, salt.size, personal.size) < 0 )
		return -1;

	FS->last_node = 1; // Mark as last node

	for( size_t i = 0; i < PARALLELISM_DEGREE; ++i )
		blake2b_update( FS, hash[i], BLAKE2B_OUTBYTES );

	blake2b_final( FS, out, outlen );;

	for (i = 0; i < outlen; i++) {
		tmphash[i] = enif_make_uint(env, out[i]);
	}

	return enif_make_list_from_array(env, tmphash, outlen);
}

static int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
	return 0;
}

static ErlNifFunc blake2bp_nif_funcs[] =
{
	{"blake2bp_hash", 5, blake2bp_hash}
};

ERL_NIF_INIT(Elixir.Blake2.Blake2bp, blake2bp_nif_funcs, NULL, NULL, upgrade, NULL)
