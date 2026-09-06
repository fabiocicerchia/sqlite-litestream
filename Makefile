IMAGE     ?= fabiocicerchia/sqlite-litestream
VERSION   ?= 0.3.13
PLATFORMS ?= linux/amd64,linux/arm64

# Every verb this repository exposes lives here; `make` on its own prints them.
# FC-GEN-057: the same eight verbs in every repo, each either wired or a
# declared no-op that says why. None of them exit 0 quietly.

.DEFAULT_GOAL := help

.PHONY: help setup install build test lint run format analyze push release

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install the pre-commit hook
	pre-commit install

build: ## Build the image locally
	docker build --build-arg LITESTREAM_VERSION=$(VERSION) -t $(IMAGE):$(VERSION) .

lint: ## Run the whole gate — every hook, every file
	pre-commit run --all-files

test: build ## Build + smoke test (write -> replicate -> restore round-trip)
	./test.sh $(IMAGE):$(VERSION)

install: ## Pull the published image onto this machine
	docker pull $(IMAGE):$(VERSION)

run: build ## Run litestream from the image (ARGS is the subcommand, default `replicate`)
	docker run --rm $(IMAGE):$(VERSION) $(ARGS)

format: ## Rewrite what the gate can fix: whitespace, line endings, final newline
	@# A fixing hook exits 1 when it rewrites a file. That is this target doing
	@# its job, not failing, so the exits are ignored — make still prints what
	@# each hook said.
	-pre-commit run --all-files trailing-whitespace
	-pre-commit run --all-files end-of-file-fixer
	-pre-commit run --all-files mixed-line-ending

analyze: ## Scan the tree the way CI does — vulnerabilities, misconfig, secrets
	@command -v trivy >/dev/null 2>&1 || { \
		echo "analyze needs trivy: https://trivy.dev/latest/getting-started/installation/" >&2; \
		exit 69; }
	trivy fs --scanners vuln,misconfig,secret --severity CRITICAL,HIGH .

push: build ## Push the single-arch image
	docker push $(IMAGE):$(VERSION)

release: ## Build and push the multi-arch image (:VERSION and :latest)
	docker buildx build --platform $(PLATFORMS) \
		--build-arg LITESTREAM_VERSION=$(VERSION) \
		-t $(IMAGE):$(VERSION) -t $(IMAGE):latest --push .
