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

NIF_SRC = c_src/blake2b.c c_src/blake2_nif.c

all: priv/blake2_nif.so

priv/blake2_nif.so: $(NIF_SRC)
	mkdir -p priv
	$(CC) $(CFLAGS) -shared $(LDFLAGS) -o $@ $(NIF_SRC)

.PHONY: all
