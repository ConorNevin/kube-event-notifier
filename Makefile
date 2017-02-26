IMAGE_PREFIX    ?= naruda
SHORT_NAME      ?= kube-event-notifier
APP             = kube-event-notifier

# go option
GO        ?= go
PKG       := $(shell glide novendor)
BINDIR    := $(CURDIR)/bin

# docker options
GIT_SHA := $(shell git rev-parse --short HEAD)
DOCKER_VERSION ?= git-${GIT_SHA}
IMAGE := ${IMAGE_PREFIX}/${SHORT_NAME}:${DOCKER_VERSION}

# Required for globs to work correctly
SHELL=/bin/bash

.PHONY: all
all: build

HAS_GLIDE := $(shell command -v glide;)
HAS_GIT := $(shell command -v git;)

.PHONY: bootstrap
bootstrap:
ifndef HAS_GLIDE
	go get -u github.com/Masterminds/glide
endif

ifndef HAS_GIT
	$(error You must install Git)
endif
	glide install --strip-vendor

.PHONY: build
build:
	GOBIN=$(BINDIR) $(GO) install $(GOFLAGS) -tags '$(TAGS)' -ldflags '$(LDFLAGS)' .

.PHONY: check-docker
check-docker:
	@if [ -z $$(which docker) ]; then \
	  echo "Missing \`docker\` client which is required for development"; \
	  exit 2; \
	fi

.PHONY: docker-build
docker-build: check-docker build
	docker build --rm -t ${IMAGE} .

.PHONY: docker-push
docker-push:
	docker push ${IMAGE}
