RUSTC ?= rustc
RUSTC_FLAGS ?=

# Link flags to pull in dependencies
BINS = cargo-read-manifest \
			 cargo-rustc \
			 cargo-verify-project

SRC = $(wildcard src/*.rs)
DEPS = -L libs/hammer.rs/target -L libs/rust-toml/lib
TOML = libs/rust-toml/lib/$(shell rustc --crate-file-name libs/rust-toml/src/toml/lib.rs)
HAMMER = libs/hammer.rs/target/$(shell rustc --crate-type=lib --crate-file-name libs/hammer.rs/src/hammer.rs)
HAMCREST = libs/hamcrest-rust/target/timestamp
LIBCARGO = target/libcargo.timestamp
BIN_TARGETS = $(patsubst %,target/%,$(BINS))

all: $(BIN_TARGETS)

# === Dependencies

$(HAMMER): $(wildcard libs/hammer.rs/src/*.rs)
	cd libs/hammer.rs && make

$(TOML): $(wildcard libs/rust-toml/src/toml/*.rs)
	cd libs/rust-toml && make

$(HAMCREST): $(wildcard libs/hamcrest-rust/src/*.rs)
	cd libs/hamcrest-rust && make

# === Cargo

$(LIBCARGO): $(SRC)
	mkdir -p target
	$(RUSTC) $(RUSTC_FLAGS) --out-dir target src/cargo.rs
	touch $(LIBCARGO)

libcargo: $(LIBCARGO)

# === Commands

$(BIN_TARGETS): target/%: src/bin/%.rs $(HAMMER) $(TOML) $(LIBCARGO)
	$(RUSTC) $(RUSTC_FLAGS) $(DEPS) -Ltarget --out-dir target $<

test:
	echo "testing"

clean:
	rm -rf target

distclean: clean
	cd libs/hamcrest-rust && make clean
	cd libs/hammer.rs && make clean
	cd libs/rust-toml && make clean

# Setup phony tasks
.PHONY: all clean distclean test libcargo

# Disable unnecessary built-in rules
.SUFFIXES: