CGO_ENABLED=0
GOOS=linux
GOARCH=amd64
REPO=janeczku/rancher-demo
VERSION=`cat ./VERSION`

all: build

test:
	@go test -v ./...

binary:
	@go build -ldflags '-w -linkmode external -extldflags -static' -o docker-demo .

build:
	@docker build --build-arg APP_VER=${VERSION} -t ${REPO}:${VERSION} .

release:
	@docker push ${REPO}:${VERSION}

.PHONY: build binary release
