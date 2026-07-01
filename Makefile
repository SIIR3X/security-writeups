SHELL := /bin/bash

# All write-up directories (any folder containing a README.md, excluding the
# repo root and the templates folder).
WRITEUPS := $(shell find . -mindepth 2 -name README.md -not -path './templates/*' -printf '%h\n')

.PHONY: pdf clean list

pdf:
	@for d in $(WRITEUPS); do ./build-pdf.sh "$$d"; done

list:
	@for d in $(WRITEUPS); do echo "$$d"; done

clean:
	@find . -mindepth 2 -name '*.pdf' -not -path './templates/*' -print -delete
