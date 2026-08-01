# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
