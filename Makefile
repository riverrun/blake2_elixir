CFLAGS = -g -O3 -Wall

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I"$(ERLANG_PATH)"
CFLAGS += -Ic_src

ifneq ($(CROSSCOMPILE),)
    # crosscompiling
    CFLAGS += -fPIC
else
    # not crosscompiling
    ifneq ($(OS),Windows_NT)
        CFLAGS += -fPIC

        ifeq ($(shell uname),Darwin)
            LDFLAGS += -dynamiclib -undefined dynamic_lookup
        endif
    endif
endif

BLAKE2B_SRC = c_src/blake2b.c c_src/blake2b_nif.c
BLAKE2S_SRC = c_src/blake2s.c c_src/blake2s_nif.c
BLAKE2BP_SRC = c_src/blake2bp.c c_src/blake2b.c
BLAKE2SP_SRC = c_src/blake2sp.c c_src/blake2s.c

all: create_priv priv/blake2b_nif.so priv/blake2s_nif.so priv/blake2bp_nif.so priv/blake2sp_nif.so

create_priv:
	mkdir -p priv

priv/blake2b_nif.so: $(BLAKE2B_SRC)
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ $(BLAKE2B_SRC)

priv/blake2s_nif.so: $(BLAKE2S_SRC)
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ $(BLAKE2S_SRC)

priv/blake2bp_nif.so: $(BLAKE2BP_SRC)
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ $(BLAKE2BP_SRC)

priv/blake2sp_nif.so: $(BLAKE2SP_SRC)
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ $(BLAKE2SP_SRC)

.PHONY: all create_priv
