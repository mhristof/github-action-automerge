MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
ifeq ($(word 1,$(subst ., ,$(MAKE_VERSION))),4)
.SHELLFLAGS := -eu -o pipefail -c
endif
.DEFAULT_GOAL := help
.ONESHELL:


BRANCH := $(shell git branch --show-current)

.PHONY: build
build: .build

.build: Dockerfile
	docker build -t automerge .

branch:
	sed -i "" -e "s!uses: mhristof/github-action-automerge@.* # THIS BRANCH!uses: mhristof/github-action-automerge@$(BRANCH) # THIS BRANCH!" .github/workflows/main.yml

.PHONY: help
help: ## Show this help.
	@grep '.*:.*##' Makefile | grep -v grep  | sort | sed 's/:.* ##/:/g' | column -t -s:
