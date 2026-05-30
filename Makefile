
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


.PHONY: update_schemadir
update_schemadir:
	@echo "update_schemadir  #  Update RDF schemas using schematool"
	schematool



.PHONY: build
build:
	@echo "build  #  Full build pipeline (aggregate data, transform markdown, build docs)"
	$(MAKE) aggregate_data transform_md_all docs


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


