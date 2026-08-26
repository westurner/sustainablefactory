LEAN ?= lake
LEAN_TOOLCHAIN ?= leanprover/lean4:v4.33.0

.PHONY: default help lean-cache lean-build lean-clean install-elan

default: lean-build

help:
	@printf '%s\n' \
		'lean-cache  # Download Mathlib/Physlib build artifacts when available' \
		'lean-build  # Build the Signals library' \
		'lean-clean  # Remove Lake build artifacts'

lean-cache:
	$(LEAN) exe cache get

lean-build:
	$(LEAN) build Signals

lean-clean:
	$(LEAN) clean

install-elan:
	curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- --default-toolchain "$(LEAN_TOOLCHAIN)" -y
	"$(HOME)/.elan/bin/lean" --version
	"$(HOME)/.elan/bin/lake" --version