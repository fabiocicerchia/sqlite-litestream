IMAGE     ?= fabiocicerchia/sqlite-litestream
VERSION   ?= 0.3.13
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: build lint test push release

build:
	docker build --build-arg LITESTREAM_VERSION=$(VERSION) -t $(IMAGE):$(VERSION) .

lint:
	docker run --rm -i hadolint/hadolint < Dockerfile
	shellcheck entrypoint.sh test.sh

test: build
	./test.sh $(IMAGE):$(VERSION)

push: build
	docker push $(IMAGE):$(VERSION)

release:
	docker buildx build --platform $(PLATFORMS) \
		--build-arg LITESTREAM_VERSION=$(VERSION) \
		-t $(IMAGE):$(VERSION) -t $(IMAGE):latest --push .
