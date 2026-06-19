
# sustainablefactory Makefile
# Build automation for documentation, data processing, and testing

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
	podman run -d -p 7700:7700 -e MEILI_MASTER_KEY=dev-key \
		--name meilisearch-dev sustainablefactory-meilisearch:latest || true

.PHONY: meilisearch_stop
meilisearch_stop:
	@echo "meilisearch_stop  #  Stop Meilisearch container"
	podman stop meilisearch-dev || true
	podman rm meilisearch-dev || true

.PHONY: meilisearch_build
meilisearch_build:
	@echo "meilisearch_build  #  Build Meilisearch Docker image"
	podman build -f Dockerfile.meilisearch -t sustainablefactory-meilisearch:latest

.PHONY: meilisearch_build_version
meilisearch_build_version:
	@echo "meilisearch_build_version  #  Build Meilisearch image with MEILISEARCH_VERSION=vX.Y.Z"
	@test -n "$(MEILISEARCH_VERSION)" || (echo "Usage: make meilisearch_build_version MEILISEARCH_VERSION=v1.15.2" && exit 1)
	podman build \
		--build-arg MEILISEARCH_VERSION=$(MEILISEARCH_VERSION) \
		-f Dockerfile.meilisearch \
		-t sustainablefactory-meilisearch:$(MEILISEARCH_VERSION)

.PHONY: meilisearch_index_chats
meilisearch_index_chats:
	@echo "meilisearch_index_chats  #  Index chat exports to Meilisearch"
	python3 -m sustainablefactory.meilisearch_integration.cli index-chats --source docs/chats

.PHONY: meilisearch_index_html
meilisearch_index_html:
	@echo "meilisearch_index_html  #  Index Sphinx HTML to Meilisearch"
	python3 -m sustainablefactory.meilisearch_integration.cli index-html --source docs/_build/html

.PHONY: meilisearch_index_all
meilisearch_index_all: meilisearch_index_chats meilisearch_index_html
	@echo "meilisearch_index_all  #  Index all sources (chats and HTML)"

.PHONY: meilisearch_status
meilisearch_status:
	@echo "meilisearch_status  #  Show Meilisearch indices and status"
	python3 -m sustainablefactory.meilisearch_integration.cli status

.PHONY: meilisearch_search
meilisearch_search:
	@echo "meilisearch_search  #  Search Meilisearch (interactive)"
	python3 -m sustainablefactory.meilisearch_integration.cli search --index all

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


