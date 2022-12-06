
PATH := $(PWD)/tooling/bin:$(PATH)
export PATH
SHELL := env PATH='$(PATH)' $(shell which bash)

.PHONY : audit
audit:
	cargo audit

#TODO: Using sanitizers likely requires a bit more setup
#      https://doc.rust-lang.org/beta/unstable-book/compiler-flags/sanitizer.html
.PHONY : test
test:
	RUSTFLAGS="-Zsanitizer=thread" cargo miri test

.PHONY : clippy
clippy:
	cargo clippy --tests -- -D warnings

.PHONY : kani
kani:
	RUSTFLAGS="--cfg kani" cargo-kani

.PHONY : flux
flux:
	tooling/bin/flux --crate-type=lib $(PWD)/src/lib.rs
	#tooling/bin/flux -L all=$(PWD)/target/x86_64-unknown-linux-gnu/debug/deps --crate-type=lib $(PWD)/src/lib.rs

# NOTE: Using shuttle as a feature here instead of config, which enables conditional dependency
.PHONY : shuttle
shuttle:
	cargo test --features shuttle

# Specifically using `clippy` over `cargo check` even if it's more opinated
.PHONY : check
check: audit clippy

.PHONY : check-all
check-all: audit clippy test kani flux

bom.xml:
	cargo cyclonedx

tooling/flux: tooling/bin
	cd tooling \
	&& wget https://get.haskellstack.org/ -O install-stack.sh \
	&& chmod +x install-stack.sh \
	&& ./install-stack.sh -d `pwd`/bin \
	&& rm install-stack.sh \
	&& wget https://github.com/Z3Prover/z3/releases/download/z3-4.11.2/z3-4.11.2-x64-glibc-2.31.zip \
	&& unzip z3-4.11.2-x64-glibc-2.31.zip \
	&& rm z3-4.11.2-x64-glibc-2.31.zip \
	&& git clone git@github.com:ucsd-progsys/liquid-fixpoint.git \
	&& cd liquid-fixpoint \
	&& ../bin/stack install --local-bin-path . \
	&& cd .. \
	&& git clone git@github.com:liquid-rust/flux.git \
	&& cd flux \
	&& cargo build \
	&& cd ../bin \
	&& ln -s ../liquid-fixpoint/fixpoint ./fixpoint \
	&& ln -s ../liquid-fixpoint/fixpoint ./liquid-fixpoint \
	&& ln -s ../z3-4.11.2-x64-glibc-2.31/bin/z3 \
	&& cp ../../scripts/flux .

tooling/bin:
	rustup component add rust-src \
	&& rustup component add miri \
	&& cargo install --locked kani-verifier \
	&& cargo-kani setup \
	&& cargo install cargo-audit \
	&& cargo install cargo-cyclonedx \
	&& mkdir -p ./tooling \
	&& cd tooling \
	&& mkdir -p ./bin \
	&& cd bin \
	&& cp ../../scripts/bw-cargo .

tooling: tooling/bin tooling/flux


