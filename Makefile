PKG_NAME=pyml_example
DLL=pywrap.so

.PHONY: build install test clean

build:
	dune build ocaml/$(DLL)
	cp _build/default/ocaml/$(DLL) $(PKG_NAME)
	chmod 0777 $(PKG_NAME)/$(DLL)

install: build
	python setup.py build
	pip install .

test:
	python test/test.py

clean:
	dune clean
	rm -rf ocaml/_build
	rm -rf build
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf pyml_example/__pycache__
	rm -f $(PKG_NAME)/$(DLL)
	rm -f ocaml/.merlin
	rm -f *.egg-info