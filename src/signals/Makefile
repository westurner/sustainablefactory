LEAN ?= lake
LEAN_TOOLCHAIN ?= leanprover/lean4:v4.35.0-rc3

.PHONY: default help lean-cache lean-build lean-api blueprint blueprint-pdf lean-clean install-elan

default: lean-build

help:
	@printf '%s\n' \
		'lean-cache  # Download Mathlib/Physlib build artifacts when available' \
		'lean-build  # Build the Signals library' \
		'lean-api  # Generate Lean API pages and the declaration finder' \
		'blueprint  # Build the HTML blueprint with its Lean API reference' \
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

lean-api:
	GIT_CONFIG_PARAMETERS="$${GIT_CONFIG_PARAMETERS:+$$GIT_CONFIG_PARAMETERS }'url.https://github.com/.insteadOf'='ssh://git@github.com/'" $(LEAN) build :docs

blueprint: lean-api
	$(LEAN) build :blueprint
	cd blueprint/src && plastex --kpsewhich ./resolve-tex-input.sh -c plastex.cfg web.tex
	ln -sfnT ../../.lake/build/doc blueprint/web/signals-api

blueprint-pdf: blueprint
	cd blueprint/src && latexmk -output-directory=../print

lean-clean:
	$(LEAN) clean

install-elan:
	curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- --default-toolchain "$(LEAN_TOOLCHAIN)" -y
	"$(HOME)/.elan/bin/lean" --version
	"$(HOME)/.elan/bin/lake" --version
