
# sustainablefactory Makefile
# Build automation for documentation, data processing, and testing

# Optional explicit virtualenv path, e.g. `make ... VENV=.venv`.
VENV ?=
PYTHON ?= $(if $(VENV),$(VENV)/bin/python,$(if $(wildcard .venv/bin/python),.venv/bin/python,$(if $(wildcard $(HOME)/.venv/bin/python),$(HOME)/.venv/bin/python,python3)))
# Installer selector: auto|uv|pip. auto prefers uv with pip fallback.
INSTALLER ?= auto
PODMAN ?= $(if $(shell command -v flatpak-spawn 2>/dev/null),flatpak-spawn podman,$(if $(shell command -v podman 2>/dev/null),podman,$(if $(shell command -v podman-remote 2>/dev/null),podman-remote,podman)))
MEILISEARCH_HOST ?= localhost
MEILISEARCH_URL ?= http://$(MEILISEARCH_HOST):7700
MEILI_MASTER_KEY ?= dev-key

.PHONY: default
default: help

.PHONY: help
help:
	@echo "help  #  Display available tasks and their descriptions"
	@grep -E '^\s+@echo "[^:]+  #  ' Makefile | sed 's/^\s*@echo "//' | sed 's/"$$//'

.PHONY: docs
docs:
	@echo "docs  #  Build Sphinx documentation"
	$(MAKE) -C docs html


.PHONY: generate_glossary
generate_glossary:
	@echo "generate_glossary  #  Regenerate docs/glossary.md from docs/glossary.yaml"
	docindex generate-glossary

.PHONY: export_synonyms
export_synonyms:
	@echo "export_synonyms  #  Export synonym lists from glossary.yaml into synonyms.yaml"
	docindex export-synonyms

.PHONY: sync_glossary
sync_glossary: export_synonyms generate_glossary
	@echo "sync_glossary  #  Full glossary sync: export synonyms, regenerate glossary.md"
	@echo "  Next step: run 'make meilisearch_update_synonyms' to push to Meilisearch."

.PHONY: meilisearch_update_synonyms
meilisearch_update_synonyms:  # meilisearch_install_python
	@echo "meilisearch_update_synonyms  #  Push synonyms.yaml to all Meilisearch indices"
	docindex update-synonyms


.PHONY: aggregate_data
aggregate_data:
	@echo "aggregate_data  #  Aggregate technical data from documents"
	python3 tools/aggregate_technical_data.py


.PHONY: transform_md_all
transform_md_all:
	@echo "transform_md_all  #  Transform markdown chat exports from chatoverlay to docs"
	transform-md --indir data/chatoverlay/chats__all/ --outdir docs/chats/ --transform-cell-split m1 --out-format=myst,ipynb,chatexport_abc1

.PHONY: transform_md_data_chats
transform_md_data_chats:
	@echo "transform_md_data_chats  #  Transform markdown chat exports from data/chats to docs"
	transform-md --indir data/chats/ --outdir docs/chats/ --transform-cell-split m1 --out-format=myst,ipynb,chatexport_abc1


.PHONY: meilisearch_start
meilisearch_start:
	@echo "meilisearch_start  #  Start Meilisearch server in container or with binary"
	@if $(PODMAN) ps -a --format '{{.Names}}' 2>/dev/null | grep -q '^meilisearch-dev$$'; then \
		echo "Container exists, starting..."; \
		$(PODMAN) start meilisearch-dev || true; \
	else \
		echo "Creating new container..."; \
		$(PODMAN) run -d -p 7700:7700 -e MEILI_MASTER_KEY=$(MEILI_MASTER_KEY) \
			--name meilisearch-dev sustainablefactory-meilisearch:latest || true; \
	fi
	@sleep 1 && echo "Meilisearch should be starting on localhost:7700..."

.PHONY: meilisearch_stop
meilisearch_stop:
	@echo "meilisearch_stop  #  Stop Meilisearch container"
	$(PODMAN) stop meilisearch-dev 2>/dev/null || true
	$(PODMAN) rm meilisearch-dev 2>/dev/null || true

.PHONY: meilisearch_configure_token
meilisearch_configure_token:
	@echo "meilisearch_configure_token  #  Create a Meilisearch API key using the master key"
	curl \
		-X POST '$(MEILISEARCH_URL)/keys' \
		-H 'Content-Type: application/json' \
		-H 'Authorization: Bearer $(MEILI_MASTER_KEY)' \
		--data-binary '{"name":"Default Key","description":"Key with all permissions for all indexes","actions":["*"],"indexes":["*"],"expiresAt":null}'

.PHONY: meilisearch_build
meilisearch_build:
	@echo "meilisearch_build  #  Build Meilisearch Docker image"
	$(PODMAN) build -f Dockerfile.meilisearch -t sustainablefactory-meilisearch:latest

.PHONY: meilisearch_build_version
meilisearch_build_version:
	@echo "meilisearch_build_version  #  Build Meilisearch image with MEILISEARCH_VERSION=vX.Y.Z"
	@test -n "$(MEILISEARCH_VERSION)" || (echo "Usage: make meilisearch_build_version MEILISEARCH_VERSION=v1.15.2" && exit 1)
	$(PODMAN) build \
		--build-arg MEILISEARCH_VERSION=$(MEILISEARCH_VERSION) \
		--build-arg MEILISEARCH_NO_ANALYTICS=$(MEILISEARCH_NO_ANALYTICS) \
		-f Dockerfile.meilisearch \
		-t sustainablefactory-meilisearch:$(MEILISEARCH_VERSION)

.PHONY: meilisearch_index_chats
meilisearch_index_chats: # meilisearch_install_python
	@echo "meilisearch_index_chats  #  Index chat exports to Meilisearch"
	$(PYTHON) -m docindex_cli.cli index-chats --source docs/chats --progress --pipeline

.PHONY: meilisearch_index_html
meilisearch_index_html: # meilisearch_install_python
	@echo "meilisearch_index_html  #  Index Sphinx HTML to Meilisearch"
	$(PYTHON) -m docindex_cli.cli index-html --source docs/_build/html --progress --pipeline

.PHONY: meilisearch_index_all
meilisearch_index_all: meilisearch_index_chats meilisearch_index_html
	@echo "meilisearch_index_all  #  Index all sources (chats and HTML)"

.PHONY: meilisearch_drop_all_indexes
meilisearch_drop_all_indexes: # meilisearch_install_python
	@echo "meilisearch_drop_all_indexes  #  Drop all Meilisearch indexes (non-interactive)"
	$(PYTHON) -m docindex_cli.cli delete-index --index all --confirm
	$(PYTHON) -m docindex_cli.cli delete-index --index chats --confirm
	$(PYTHON) -m docindex_cli.cli delete-index --index sphinx --confirm

.PHONY: meilisearch_status
meilisearch_status: # meilisearch_install_python
	@echo "meilisearch_status  #  Show Meilisearch indices and status"
	$(PYTHON) -m docindex_cli.cli status

.PHONY: meilisearch_search
meilisearch_search: # meilisearch_install_python
	@echo "meilisearch_search  #  Search Meilisearch (interactive)"
	$(PYTHON) -m docindex_cli.cli search --index all

.PHONY: meilisearch_install_python
meilisearch_install_python:
	@echo "meilisearch_install_python  #  Install docindex components (INSTALLER=$(INSTALLER), PYTHON=$(PYTHON))"
	@if [ "$(INSTALLER)" = "uv" ]; then \
		uv pip install --python "$(PYTHON)" -r requirements-meilisearch.txt; \
	elif [ "$(INSTALLER)" = "pip" ]; then \
		"$(PYTHON)" -m pip install -r requirements-meilisearch.txt; \
	else \
		if command -v uv >/dev/null 2>&1; then \
			uv pip install --python "$(PYTHON)" -r requirements-meilisearch.txt; \
		else \
			"$(PYTHON)" -m pip install -r requirements-meilisearch.txt; \
		fi; \
	fi

.PHONY: meilisearch_setup_subuids
meilisearch_setup_subuids:
	@echo "meilisearch_setup_subuids  #  Add subuid/subgid entries for rootless Podman in devcontainer"
	@USER_NAME=$$(id -un); \
	RANGE_START=100000; RANGE_END=165535; RANGE_COUNT=65536; \
	echo "Setting up subordinate UID/GID mappings for: $$USER_NAME"; \
	echo "Requested range: $$RANGE_START-$$RANGE_END (count=$$RANGE_COUNT)"; \
	\
	echo "--- Checking /etc/subuid ---"; \
	if [ -f /etc/subuid ]; then \
		OVERLAPS=$$(awk -F: -v start="$$RANGE_START" -v end="$$RANGE_END" \
			'{ s=int($$2); c=int($$3); e=s+c-1; if (s<=end && e>=start) print $$0 }' /etc/subuid); \
		if [ -n "$$OVERLAPS" ]; then \
			echo "WARNING: existing subuid entries overlap with $$RANGE_START-$$RANGE_END:"; \
			echo "$$OVERLAPS"; \
		else \
			echo "No overlapping subuid ranges found."; \
		fi; \
	fi; \
	if ! grep -q "^$$USER_NAME:" /etc/subuid 2>/dev/null; then \
		sudo usermod --add-subuids "$$RANGE_START-$$RANGE_END" "$$USER_NAME" && \
		echo "Added subuid range $$RANGE_START-$$RANGE_END for $$USER_NAME"; \
	else \
		echo "subuid entry already exists for $$USER_NAME:"; \
		grep "^$$USER_NAME:" /etc/subuid; \
	fi; \
	\
	echo "--- Checking /etc/subgid ---"; \
	if [ -f /etc/subgid ]; then \
		OVERLAPS=$$(awk -F: -v start="$$RANGE_START" -v end="$$RANGE_END" \
			'{ s=int($$2); c=int($$3); e=s+c-1; if (s<=end && e>=start) print $$0 }' /etc/subgid); \
		if [ -n "$$OVERLAPS" ]; then \
			echo "WARNING: existing subgid entries overlap with $$RANGE_START-$$RANGE_END:"; \
			echo "$$OVERLAPS"; \
		else \
			echo "No overlapping subgid ranges found."; \
		fi; \
	fi; \
	if ! grep -q "^$$USER_NAME:" /etc/subgid 2>/dev/null; then \
		sudo usermod --add-subgids "$$RANGE_START-$$RANGE_END" "$$USER_NAME" && \
		echo "Added subgid range $$RANGE_START-$$RANGE_END for $$USER_NAME"; \
	else \
		echo "subgid entry already exists for $$USER_NAME:"; \
		grep "^$$USER_NAME:" /etc/subgid; \
	fi
	@echo "--- Final state ---"
	@echo "Current /etc/subuid:"; cat /etc/subuid
	@echo "Current /etc/subgid:"; cat /etc/subgid
	@echo "Run 'podman system migrate' if Podman was already used before this change."

.PHONY: update_schemadir
update_schemadir:
	@echo "update_schemadir  #  Update RDF schemas using schematool"
	schematool



.PHONY: build
build:
	@echo "build  #  Full build pipeline (aggregate data, transform markdown, build docs)"
	$(MAKE) aggregate_data transform_md_all docs

.PHONY: build_with_search
build_with_search:
	@echo "build_with_search  #  Build docs and index to Meilisearch"
	$(MAKE) build meilisearch_index_html


.PHONY: test
test:
	@echo "test  #  Run test suite"
	$(MAKE) pytest

.PHONY: pytest
pytest:
	@echo "pytest  #  Run pytest with coverage report"
	pytest --cov=. --cov-report=term-missing .


.PHONY: e2etest
e2etest:
	@echo "e2etest  #  Run end-to-end tests with Playwright"
	./e2etest.sh --on-host


.PHONY: serve
serve:
	@echo "serve  #  Serve docs with HTTP server on port 8000"
	(type -a tree && tree -a -L 2 ./docs/_build/html) || true
	python3 -m http.server 8000 --directory docs/_build/html


