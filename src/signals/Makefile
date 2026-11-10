LEAN ?= lake
LEAN_TOOLCHAIN ?= leanprover/lean4:v4.35.0-rc3
LAKE_FLAGS ?=
PROFILE ?= 0
DOCGEN_PROFILE ?= 0
DOCGEN_DEBUG ?= 0
DISABLE_EQUATIONS ?= 1
PYTHON ?= python3
PROFILE_RUN = $(PYTHON) -c 'import resource, subprocess, sys, time; start = time.perf_counter(); result = subprocess.run(sys.argv[2:]); usage = resource.getrusage(resource.RUSAGE_CHILDREN); print(f"[profile] wall={time.perf_counter() - start:.3f}s user={usage.ru_utime:.3f}s sys={usage.ru_stime:.3f}s maxrss={usage.ru_maxrss}KiB", file=sys.stderr); sys.exit(result.returncode)' --

define run-profiled
	@printf '\n==> %s\n' '$(1)'
	@if [ "$(PROFILE)" = "1" ]; then \
		$(PROFILE_RUN) $(2); \
	else \
		$(2); \
	fi
endef

.PHONY: default help lean-cache lean-build lean-api blueprint blueprint-profile blueprint-pdf lean-clean install-elan

default: lean-build

help:
	@printf '%s\n' \
		'lean-cache  # Download Mathlib/Physlib build artifacts when available' \
		'lean-build  # Build the Signals library' \
		'lean-api  # Generate Signals API pages (DISABLE_EQUATIONS=0 enables equations)' \
		'blueprint  # Build the HTML blueprint with its Lean API reference' \
		'blueprint-profile  # Profile Lean, doc-gen4, and blueprint phases' \
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
	$(LEAN) $(LAKE_FLAGS) build Signals SignalsTests SignalsPending SignalsPendingTests

lean-api:
	$(call run-profiled,Compile Signals,env \
		DISABLE_EQUATIONS=$(DISABLE_EQUATIONS) \
		GIT_CONFIG_PARAMETERS="$${GIT_CONFIG_PARAMETERS:+$$GIT_CONFIG_PARAMETERS }'url.https://github.com/.insteadOf'='ssh://git@github.com/'" \
		$(LEAN) $(LAKE_FLAGS) build Signals @doc-gen4/coreDocs signalsApiDocs)
	$(call run-profiled,Generate Signals API pages,env \
		DISABLE_EQUATIONS=$(DISABLE_EQUATIONS) \
		SIGNALS_DOCGEN_PROFILE=$(DOCGEN_PROFILE) \
		SIGNALS_DOCGEN_DEBUG=$(DOCGEN_DEBUG) \
		$(LEAN) $(LAKE_FLAGS) env python3 build_api_docs.py)

blueprint: lean-api
	$(call run-profiled,Compile LeanArchitect blueprint data,$(LEAN) $(LAKE_FLAGS) build :blueprint)
	@set -eu; \
		stamp=".lake/build/blueprint-web.sha256"; \
		current="$$( { \
			find blueprint/src .lake/build/blueprint -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum; \
			sha256sum Makefile requirements-blueprint.txt; \
		} | sha256sum | cut -d' ' -f1)"; \
		if [ ! -f "$$stamp" ] || [ "$$(cat "$$stamp")" != "$$current" ] || [ ! -f blueprint/web/index.html ]; then \
			printf '%s\n' '==> Render blueprint HTML'; \
			if [ "$(PROFILE)" = "1" ]; then \
				(cd blueprint/src && $(PROFILE_RUN) plastex --kpsewhich ./resolve-tex-input.sh -c plastex.cfg web.tex); \
			else \
				(cd blueprint/src && plastex --kpsewhich ./resolve-tex-input.sh -c plastex.cfg web.tex); \
			fi; \
			printf '%s\n' "$$current" > "$$stamp"; \
		else \
			printf '%s\n' 'Blueprint HTML unchanged; reusing generated output'; \
		fi; \
		ln -sfnT ../../.lake/build/doc blueprint/web/signals-api

blueprint-profile: PROFILE = 1
blueprint-profile: DOCGEN_PROFILE = 1
blueprint-profile: DOCGEN_DEBUG = 1
blueprint-profile: LAKE_FLAGS = -v
blueprint-profile: blueprint

blueprint-pdf: blueprint
	cd blueprint/src && latexmk -output-directory=../print

lean-clean:
	$(LEAN) clean

install-elan:
	curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- --default-toolchain "$(LEAN_TOOLCHAIN)" -y
	"$(HOME)/.elan/bin/lean" --version
	"$(HOME)/.elan/bin/lake" --version
