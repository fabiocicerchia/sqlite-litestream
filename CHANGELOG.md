# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2](https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.4.1...v0.4.2) (2026-09-04)


### Bug Fixes

* **ci:** pin the editorconfig-checker binary version ([#52](https://github.com/fabiocicerchia/sqlite-litestream/issues/52)) ([033429a](https://github.com/fabiocicerchia/sqlite-litestream/commit/033429ab196f2c8fcd75ded80b7b25b87d2ec1d5))

## [0.4.1](https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.4.0...v0.4.1) (2026-08-29)


### Bug Fixes

* unblock quality and clear the Scorecard pinned-dependencies finding ([#45](https://github.com/fabiocicerchia/sqlite-litestream/issues/45)) ([a5e08b1](https://github.com/fabiocicerchia/sqlite-litestream/commit/a5e08b17c7ea51556fc7a0e0bd160e585ddb2973))

## [0.4.0](https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.3.0...v0.4.0) (2026-08-25)


### Features

* **docs:** build the docs site in Actions and drop Read the Docs ([#41](https://github.com/fabiocicerchia/sqlite-litestream/issues/41)) ([f6ce339](https://github.com/fabiocicerchia/sqlite-litestream/commit/f6ce3399968df9551a92d38313dc1d08b2c89003))
* **docs:** link the splash to the rendered site and its palette ([#43](https://github.com/fabiocicerchia/sqlite-litestream/issues/43)) ([e3a3f6f](https://github.com/fabiocicerchia/sqlite-litestream/commit/e3a3f6f4837441a93d785c0ae9e20aebb760f56b))

## [0.3.0](https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.2.2...v0.3.0) (2026-08-14)


### Features

* add optional client-side age encryption ([#35](https://github.com/fabiocicerchia/sqlite-litestream/issues/35)) ([990fb80](https://github.com/fabiocicerchia/sqlite-litestream/commit/990fb80d013f29a4088c75bf09061b4ef91383ff))

## [0.2.2](https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.2.1...v0.2.2) (2026-08-13)


### Bug Fixes

* security and code-quality findings ([#31](https://github.com/fabiocicerchia/sqlite-litestream/issues/31)) ([e8debcc](https://github.com/fabiocicerchia/sqlite-litestream/commit/e8debccb754649a2e053d735ec7fb4a6070958c1))

## [0.2.1](https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.2.0...v0.2.1) (2026-08-08)


### Bug Fixes

* publish the image from the release job so it actually runs ([2f13bb1](https://github.com/fabiocicerchia/sqlite-litestream/commit/2f13bb1c987c2f5f830efba567189a525c5fe353))

## [0.2.0](https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.1.1...v0.2.0) (2026-08-06)


### Features

* **chart:** add Helm chart ([4898133](https://github.com/fabiocicerchia/sqlite-litestream/commit/489813327b721e6ccf3fddb81e290d1fa5c7acef))


### Bug Fixes

* **pre-commit:** stop check-yaml failing on Helm templates and multi-doc manifests ([41df72f](https://github.com/fabiocicerchia/sqlite-litestream/commit/41df72f8429959d345216708792def73ad3e64a3))
* **security:** skip the SARIF upload on private repos ([e0e4780](https://github.com/fabiocicerchia/sqlite-litestream/commit/e0e47805fecd4f9874f6924c1856e90ee63875ca))

## [0.1.1](https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.1.0...v0.1.1) (2026-07-31)


### Bug Fixes

* use exec form for the HEALTHCHECK so hadolint stops failing CI ([42c871d](https://github.com/fabiocicerchia/sqlite-litestream/commit/42c871da782b58a2a7128b077ce82b61af1fba40))
* use exec form for the HEALTHCHECK so hadolint stops failing CI ([74572e4](https://github.com/fabiocicerchia/sqlite-litestream/commit/74572e45326b437dffc8342542422a19d97a5afe))

## [Unreleased]

## [0.1.0]

### Added

- Docker image bundling SQLite and Litestream for real-time S3 replication.
- Entrypoint script handling Litestream replica restore on startup.
- Multi-arch image build (`linux/amd64`, `linux/arm64`) published to GHCR.
- Environment-based configuration for S3 endpoint, bucket, and credentials.

[Unreleased]: https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fabiocicerchia/sqlite-litestream/releases/tag/v0.1.0
