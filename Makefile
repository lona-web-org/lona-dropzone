SHELL=/bin/bash
PYTHON=python3
PYTHON_ENV=env
DIST_ROOT=lona_dropzone/static/lona-dropzone/dist


.PHONY: clean npm-dependencies test-script dist _release

clean:
	rm -rf node_modules
	rm -rf $(PYTHON_ENV)

# python ######################################################################
$(PYTHON_ENV): pyproject.toml
	rm -rf $(PYTHON_ENV) && \
	$(PYTHON) -m venv $(PYTHON_ENV) && \
	. $(PYTHON_ENV)/bin/activate && \
	pip install pip --upgrade && \
	pip install -e .[dev]

# npm #########################################################################
node_modules: package.json
	npm install

npm-dependencies: | node_modules
	rm -rf $(DIST_ROOT)
	mkdir -p $(DIST_ROOT)

	cp node_modules/dropzone/LICENSE $(DIST_ROOT)
	cp node_modules/dropzone/dist/* $(DIST_ROOT)

# tests ########################################################################
test-script: $(PYTHON_ENV)
	. $(PYTHON_ENV)/bin/activate && \
	$(PYTHON) test-script.py $(args)

# packaging ###################################################################
dist: $(PYTHON_ENV)
	. $(PYTHON_ENV)/bin/activate && \
	rm -rf dist *.egg-info && \
	python -m build

_release: dist
	. $(PYTHON_ENV)/bin/activate && \
	twine upload --config-file ~/.pypirc.fscherf dist/*
