LEAN ?= lake
LEAN_TOOLCHAIN ?= leanprover/lean4:v4.35.0-rc3

.PHONY: default help lean-cache lean-build blueprint blueprint-pdf lean-clean install-elan

default: lean-build

help:
	@printf '%s\n' \
		'lean-cache  # Download Mathlib/Physlib build artifacts when available' \
		'lean-build  # Build the Signals library' \
		'blueprint  # Extract Lean nodes and build the HTML blueprint' \
		'blueprint-pdf  # Build the printable blueprint (requires TeX)' \
		'lean-clean  # Remove Lake build artifacts'

lean-cache:
	@#$(LEAN) update
	@if $(LEAN) exe cache get; then \
		echo "Lean cache restored"; \
	else \
		echo "Lean cache unavailable; continuing with a local build"; \
	fi

lean-build:
	$(LEAN) build Signals SignalsTests SignalsPending SignalsPendingTests

blueprint:
	$(LEAN) build :blueprint
	cd blueprint/src && plastex --kpsewhich ./resolve-tex-input.sh -c plastex.cfg web.tex

blueprint-pdf: blueprint
	cd blueprint/src && latexmk -output-directory=../print

lean-clean:
	$(LEAN) clean

install-elan:
	curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- --default-toolchain "$(LEAN_TOOLCHAIN)" -y
	"$(HOME)/.elan/bin/lean" --version
	"$(HOME)/.elan/bin/lake" --version
