# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0](https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.1.0...v0.2.0) (2026-07-29)


### Features

* add install.sh one-liner installer ([e77cc7f](https://github.com/fabiocicerchia/sqlite-litestream/commit/e77cc7fdba3ee5acd790523169163bde2601fde9))


### Bug Fixes

* don't require REPLICA_URL for web mode ([f104300](https://github.com/fabiocicerchia/sqlite-litestream/commit/f1043008179bb8a2a815ea1e5bbc301f9b6fe75a))
* stop tracking gandalf's generated reports/ directory ([b9afce4](https://github.com/fabiocicerchia/sqlite-litestream/commit/b9afce4739187b0cd850559384ee70e0fe065357))
* stop tracking gandalf's generated reports/ directory ([330aa1d](https://github.com/fabiocicerchia/sqlite-litestream/commit/330aa1dba2382c26969836d3eb23af0c09b64e13))

## [Unreleased]

## [0.1.0]

### Added

- Docker image bundling SQLite and Litestream for real-time S3 replication.
- Entrypoint script handling Litestream replica restore on startup.
- Multi-arch image build (`linux/amd64`, `linux/arm64`) published to GHCR.
- Environment-based configuration for S3 endpoint, bucket, and credentials.

[Unreleased]: https://github.com/fabiocicerchia/sqlite-litestream/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fabiocicerchia/sqlite-litestream/releases/tag/v0.1.0
