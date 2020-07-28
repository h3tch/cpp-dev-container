# Makefile Version: 1.0.0

include config

SHELL = /bin/bash
CUR_DIR := $(abspath .)
DOCKER_IMAGE_VERSION ?= latest
DOCKER_IMAGE_TAG ?= $(PROJECT_NAME):$(DOCKER_IMAGE_VERSION)
DOCKER_BUILD_NO_CACHE ?= --no-cache
DOCKER_RUN_COMMAND := docker run --rm -it --env-file ./config -v $(CUR_DIR):/workspace -w=/workspace --name $(PROJECT_NAME) $(DOCKER_IMAGE_TAG)

CMAKE_BUILD_COMMAND := $()
is_inside_container := $(shell awk -F/ '$$2 == "docker"' /proc/self/cgroup | wc -l)

BUILD_TYPE ?= RelWithDebInfo

.PHONY: build rebuild compile test deploy shell upgrade

rebuild:
ifeq ($(is_inside_container), 0)
	docker build --rm $(DOCKER_BUILD_NO_CACHE) -t $(DOCKER_IMAGE_TAG) .
else
	@echo "Must be executed outside the container."
endif

build: DOCKER_BUILD_NO_CACHE:=
build: rebuild;

compile:
ifeq ($(is_inside_container), 0)
	@$(DOCKER_RUN_COMMAND) /bin/bash -c "make compile"
else
	-@rm -rf build
	@mkdir build
	@source config && cd build && conan install .. && cmake -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) .. && cmake --build .
endif

test:
ifeq ($(is_inside_container), 0)
	@$(DOCKER_RUN_COMMAND) /bin/bash -c "make test"
else
	@make --directory build test
endif

deploy:
ifeq ($(is_inside_container), 0)
	@echo "Deploy the package."
else
	@echo "Must be executed outside the container."
endif

shell:
ifeq ($(is_inside_container), 0)
	$(DOCKER_RUN_COMMAND) /bin/bash
else
	@echo "You are already inside the container."
endif

upgrade:
ifeq ($(is_inside_container), 0)
	@echo "Upgrade the Makefile."
else
	@echo "Must be executed outside the container."
endif
