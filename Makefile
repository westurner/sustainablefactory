

.PHONY: default help docs aggregate_data transform_md_all test pytest serve e2etest

default: help

help:
	@echo todo

docs:
	$(MAKE) -C docs html

aggregate_data:
	python3 tools/aggregate_technical_data.py

transform_md_all:
	transform-md --indir data/chatoverlay/chats__all/ --outdir docs/chats/ --transform-cell-split m1 --out-format=myst,ipynb,chatexport_abc1


transform_md_data_chats:
	transform-md --indir data/chats/ --outdir docs/chats/ --transform-cell-split m1 --out-format=myst,ipynb,chatexport_abc1

update_schemadir:
	schematool

test: pytest

build: aggregate_data transform_md_all docs

pytest:
	pytest --cov=. --cov-report=term-missing .

serve:
	(type -a tree && tree -a -L 2 ./docs/_build/html) || true
	python3 -m http.server 8000 --directory docs/_build/html



e2etest:
	./e2etest.sh --on-host
