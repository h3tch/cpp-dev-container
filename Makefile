# Makefile Version: 1.0.0

include config

# Compile docker variables
DOCKER_IMAGE_VERSION ?= latest
DOCKER_IMAGE_TAG ?= $(PROJECT_NAME):$(DOCKER_IMAGE_VERSION)
DOCKER_BUILD_NO_CACHE ?= --no-cache
DOCKER_RUN_COMMAND := docker run --rm -it --env-file ./config -v $(abspath .):/workspace -w=/workspace --name $(PROJECT_NAME) $(DOCKER_IMAGE_TAG)

OUT_DIR = out

# Set the default shell
SHELL = /bin/bash
.DEFAULT_GOAL := help

# Compute variables
is_inside_container := $(shell awk -F/ '$$2 == "docker"' /proc/self/cgroup | wc -l)


# MAKEFILE TARGETS

.PHONY: help build rebuild release debug test package deploy shell compile-readme upgrade

help: ## | Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

rebuild: ## | Rebuild the docker container image (no cache).
ifeq ($(is_inside_container), 0)
	docker build --rm $(DOCKER_BUILD_NO_CACHE) -t $(DOCKER_IMAGE_TAG) .
else
	@echo "Must be executed outside the container."
endif

build: DOCKER_BUILD_NO_CACHE:=
build: rebuild; ## | Build the docker container image, but use the cache for already successful build stages.

release: ## | Compile the source code inside the container.
ifeq ($(is_inside_container), 0)
	@$(DOCKER_RUN_COMMAND) /bin/bash -c "make compile"
else
	-@rm -rf $(OUT_DIR)
	@mkdir $(OUT_DIR)
	@cd $(OUT_DIR) && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .. && cmake --build .
endif

debug: ## | Compile the source code inside the container.
ifeq ($(is_inside_container), 0)
	@$(DOCKER_RUN_COMMAND) /bin/bash -c "make compile"
else
	-@rm -rf $(OUT_DIR)
	@mkdir $(OUT_DIR)
	@cd $(OUT_DIR) && cmake -DCMAKE_BUILD_TYPE=Debug .. && cmake --build .
endif

test: ## | Run the test inside the container.
ifeq ($(is_inside_container), 0)
	@$(DOCKER_RUN_COMMAND) /bin/bash -c "make test"
else
	@make --directory $(OUT_DIR) test
endif

package: ## | Build a package out of the binaries.
ifeq ($(is_inside_container), 0)
	@$(DOCKER_RUN_COMMAND) /bin/bash -c "make package"
else
	@make --directory $(OUT_DIR) package
endif

deploy: ## | Upload the packages to the package server.
ifeq ($(is_inside_container), 0)
	@echo "Deploy the package."
else
	@echo "Must be executed outside the container."
endif

shell: ## | Start a terminal inside the container.
ifeq ($(is_inside_container), 0)
	$(DOCKER_RUN_COMMAND) /bin/bash
else
	@echo "You are already inside the container."
endif

compile-readme: ## | Compile a readme file from the Makefile documentation.
	@sed -ne '/@sed/!s/^## //p' Makefile > readme.md
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "%-14s %s\n", $$1, $$2}' Makefile >> readme.md

upgrade: ## | Upgrade this Makefile to the newest version.
ifeq ($(is_inside_container), 0)
	@echo "Upgrade the Makefile."
else
	@echo "Must be executed outside the container."
endif
