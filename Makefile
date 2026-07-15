IMAGE     ?= fabiocicerchia/sqlite-litestream
VERSION   ?= 0.3.13
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: help setup build lint test push release

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install git hooks (gitleaks) and pre-commit
	git config core.hooksPath .githooks
	@command -v pre-commit >/dev/null 2>&1 && pre-commit install || true

build: ## Build the image locally
	docker build --build-arg LITESTREAM_VERSION=$(VERSION) -t $(IMAGE):$(VERSION) .

lint: ## hadolint (Dockerfile) + shellcheck (shell scripts)
	docker run --rm -i hadolint/hadolint < Dockerfile
	shellcheck entrypoint.sh test.sh

test: build ## Build + smoke test (write -> replicate -> restore round-trip)
	./test.sh $(IMAGE):$(VERSION)

push: build ## Push the single-arch image
	docker push $(IMAGE):$(VERSION)

release: ## Build and push the multi-arch image (:VERSION and :latest)
	docker buildx build --platform $(PLATFORMS) \
		--build-arg LITESTREAM_VERSION=$(VERSION) \
		-t $(IMAGE):$(VERSION) -t $(IMAGE):latest --push .
