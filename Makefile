SHELL := /bin/bash
ROOT := $$(git rev-parse --show-toplevel)

.PHONY: docs

docs:
	@terraform-docs markdown table --output-file "$(ROOT)/README.md" --output-mode inject "$(ROOT)"
