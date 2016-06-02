CFLAGS = -g -O3 -Wall

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)
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

all: create_priv priv/blake2b_nif.so priv/blake2s_nif.so

create_priv:
	mkdir -p priv

priv/blake2b_nif.so: c_src/blake2b.c
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ c_src/blake2b.c

priv/blake2s_nif.so: c_src/blake2s.c
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ c_src/blake2s.c

.PHONY: all create_priv
