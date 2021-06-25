CGO_ENABLED=0
GOOS=linux
GOARCH=amd64
REPO=janeczku/rancher-demo
GO111MODULE=on

GITHUB_SHA ?= $(shell git rev-parse HEAD)
COMMIT = $(shell echo $(GITHUB_SHA) | head -c 6)
# GITHUB_REF ?= $(shell git rev-parse --abbrev-ref HEAD)

GIT_TREE_STATE=$(shell (git status --porcelain | grep -q .) && echo dirty || echo clean)

ifdef GITHUB_REF
	VERSION ?= $(shell echo $(GITHUB_REF) | sed 's/^refs\/tags\///')
else
	VERSION ?= $(shell [ -d .git ] && git describe --tags --always --dirty="-dev")
endif

ifeq ($(VERSION),)
	VERSION := "dev-${COMMIT}"
endif

all: build

ensure-tag:
ifndef TAG
	$(error Please invoke with `make TAG=<version> release`)
endif

test:
	@go test -v .

binary:
	@go build -ldflags="-X main.buildVer=${VERSION} -w -linkmode external -extldflags -static" -o rancher-demo .

build:
	@docker build --build-arg version=${VERSION} -t ${REPO}:${VERSION} .

push:
	@docker push ${REPO}:${VERSION}

release: ensure-tag
ifeq ($(GIT_TREE_STATE),dirty)
	$(error git state is not clean)
endif
	git tag -a $(TAG) -m "Release $(TAG)"
	git push --tags

.PHONY: build push test binary release ensure-tag
