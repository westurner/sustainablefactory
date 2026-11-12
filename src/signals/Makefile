LEAN ?= lake
LEAN_TOOLCHAIN ?= leanprover/lean4:v4.35.0-rc3
LAKE_FLAGS ?=
PROFILE ?= 0
DOCGEN_PROFILE ?= 0
DOCGEN_DEBUG ?= 0
DISABLE_EQUATIONS ?= 1
PYTHON ?= python3
LOCAL_TMP ?= $(abspath ../../.tmp)
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
	@set -eu; \
		mkdir -p .lake/build "$(LOCAL_TMP)"; \
		export TMPDIR="$(LOCAL_TMP)"; \
		stamp=".lake/build/lean-api-inputs.sha256"; \
		current="$$( { \
			find Signals -name '*.lean' -type f -print0 | LC_ALL=C sort -z | xargs -0r sha256sum; \
			sha256sum Signals.lean SignalsApiDocs.lean build_api_docs.py Makefile lakefile.toml lake-manifest.json; \
			printf 'DISABLE_EQUATIONS=%s\n' "$(DISABLE_EQUATIONS)"; \
		} | sha256sum | cut -d' ' -f1)"; \
		if [ "$${SIGNALS_API_FORCE_REBUILD:-0}" != "1" ] && [ -f "$$stamp" ] && [ "$$(cat "$$stamp")" = "$$current" ] && [ -f .lake/build/doc/Signals.html ] && [ -f .lake/build/bin/signalsApiDocs ]; then \
			printf '%s\n' 'Signals API inputs unchanged; reusing cached output'; \
		else \
			printf '\n==> Compile Signals\n'; \
			env TMPDIR="$(LOCAL_TMP)" DISABLE_EQUATIONS=$(DISABLE_EQUATIONS) \
				GIT_CONFIG_PARAMETERS="$${GIT_CONFIG_PARAMETERS:+$$GIT_CONFIG_PARAMETERS }'url.https://github.com/.insteadOf'='ssh://git@github.com/'" \
				$(LEAN) $(LAKE_FLAGS) build Signals @doc-gen4/coreDocs signalsApiDocs; \
			printf '\n==> Generate Signals API pages\n'; \
			env TMPDIR="$(LOCAL_TMP)" DISABLE_EQUATIONS=$(DISABLE_EQUATIONS) \
				SIGNALS_DOCGEN_PROFILE=$(DOCGEN_PROFILE) \
				SIGNALS_DOCGEN_DEBUG=$(DOCGEN_DEBUG) \
				$(LEAN) $(LAKE_FLAGS) env $(PYTHON) build_api_docs.py; \
			printf '%s\n' "$$current" > "$$stamp"; \
		fi

blueprint: lean-api
	@set -eu; \
		mkdir -p .lake/build blueprint/web "$(LOCAL_TMP)"; \
		export TMPDIR="$(LOCAL_TMP)"; \
		lean_stamp=".lake/build/blueprint-lean-inputs.sha256"; \
		lean_current="$$( { \
			find Signals -name '*.lean' -type f -print0 | LC_ALL=C sort -z | xargs -0r sha256sum; \
			sha256sum Signals.lean SignalsTests.lean SignalsPending.lean SignalsPendingTests.lean build_api_docs.py lakefile.toml lake-manifest.json; \
		} | sha256sum | cut -d' ' -f1)"; \
		if [ "$${SIGNALS_API_FORCE_REBUILD:-0}" != "1" ] && [ -f "$$lean_stamp" ] && [ "$$(cat "$$lean_stamp")" = "$$lean_current" ] && [ -f .lake/build/blueprint/library/Signals.tex ]; then \
			printf '%s\n' 'LeanArchitect blueprint data unchanged; reusing cached .tex artifacts'; \
		else \
			printf '\n==> Compile LeanArchitect blueprint data\n'; \
			if [ "$(PROFILE)" = "1" ] || [ "$(DOCGEN_DEBUG)" = "1" ]; then \
				$(LEAN) $(LAKE_FLAGS) build :blueprint; \
			else \
				if ! $(LEAN) $(LAKE_FLAGS) build :blueprint > .lake/build/blueprint-lake.log 2>&1; then \
					tail -n 60 .lake/build/blueprint-lake.log >&2; \
					exit 1; \
				fi; \
			fi; \
			$(PYTHON) build_api_docs.py --sanitize-blueprint-tex; \
			printf '%s\n' "$$lean_current" > "$$lean_stamp"; \
		fi; \
		stamp=".lake/build/blueprint-web.sha256"; \
		current="$$( { \
			find blueprint/src .lake/build/blueprint -type f ! -name '*.paux' -print0 | LC_ALL=C sort -z | xargs -0r sha256sum; \
			sha256sum Makefile build_api_docs.py requirements-blueprint.txt; \
		} | sha256sum | cut -d' ' -f1)"; \
		if [ "$${SIGNALS_API_FORCE_REBUILD:-0}" != "1" ] && [ -f "$$stamp" ] && [ "$$(cat "$$stamp")" = "$$current" ] && [ -f blueprint/web/index.html ]; then \
			printf '%s\n' 'Blueprint HTML unchanged; reusing generated output'; \
		else \
			$(PYTHON) build_api_docs.py --sanitize-blueprint-tex; \
			printf '%s\n' '==> Render blueprint HTML'; \
			rm -f blueprint/web/sect0002.html; \
			if [ "$(PROFILE)" = "1" ]; then \
				(cd blueprint/src && $(PROFILE_RUN) plastex --kpsewhich ./resolve-tex-input.sh -c plastex.cfg web.tex); \
			else \
				if ! (cd blueprint/src && plastex --kpsewhich ./resolve-tex-input.sh -c plastex.cfg web.tex) > .lake/build/plastex.log 2>&1; then \
					tail -n 60 .lake/build/plastex.log >&2; \
					exit 1; \
				fi; \
			fi; \
			current="$$( { \
				find blueprint/src .lake/build/blueprint -type f ! -name '*.paux' -print0 | LC_ALL=C sort -z | xargs -0r sha256sum; \
				sha256sum Makefile build_api_docs.py requirements-blueprint.txt; \
			} | sha256sum | cut -d' ' -f1)"; \
			printf '%s\n' "$$current" > "$$stamp"; \
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
