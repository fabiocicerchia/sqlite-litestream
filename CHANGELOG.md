# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0]

### Added

- Docker image bundling SQLite and Litestream for real-time S3 replication.
- Entrypoint script handling Litestream replica restore on startup.
- Multi-arch image build (`linux/amd64`, `linux/arm64`) published to GHCR.
- Environment-based configuration for S3 endpoint, bucket, and credentials.

[Unreleased]: https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fabiocicerchia/sqlite-litestream/releases/tag/v0.1.0
