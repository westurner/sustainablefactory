
# sustainablefactory Makefile
# Build automation for documentation, data processing, and testing

# Optional explicit virtualenv path, e.g. `make ... VENV=.venv`.
VENV ?=
PYTHON ?= $(if $(VENV),$(VENV)/bin/python,$(if $(wildcard .venv/bin/python),.venv/bin/python,$(if $(wildcard $(HOME)/.venv/bin/python),$(HOME)/.venv/bin/python,python3)))
# Installer selector: auto|uv|pip. auto prefers uv with pip fallback.
INSTALLER ?= auto
PODMAN ?= $(if $(shell command -v flatpak-spawn 2>/dev/null),flatpak-spawn podman,podman)

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
	@echo "meilisearch_start  #  Start Meilisearch server in container"
	$(PODMAN) run -d -p 7700:7700 -e MEILI_MASTER_KEY=dev-key \
		--name meilisearch-dev sustainablefactory-meilisearch:latest || true

.PHONY: meilisearch_stop
meilisearch_stop:
	@echo "meilisearch_stop  #  Stop Meilisearch container"
	$(PODMAN) stop meilisearch-dev || true
	$(PODMAN) rm meilisearch-dev || true

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
	$(PYTHON) -m docindex_cli.cli index-chats --source docs/chats

.PHONY: meilisearch_index_html
meilisearch_index_html: # meilisearch_install_python
	@echo "meilisearch_index_html  #  Index Sphinx HTML to Meilisearch"
	$(PYTHON) -m docindex_cli.cli index-html --source docs/_build/html

.PHONY: meilisearch_index_all
meilisearch_index_all: meilisearch_index_chats meilisearch_index_html
	@echo "meilisearch_index_all  #  Index all sources (chats and HTML)"

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


