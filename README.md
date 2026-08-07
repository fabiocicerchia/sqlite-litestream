# sqlite-litestream

[![CI](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/code-quality.yml/badge.svg)](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/code-quality.yml)
[![Security](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/security.yml/badge.svg)](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/security.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/fabiocicerchia/sqlite-litestream/badge)](https://securityscorecards.dev/viewer/?uri=github.com/fabiocicerchia/sqlite-litestream)
[![CI carbon](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/fabiocicerchia/sqlite-litestream/gh-pages/badge.json)](.github/workflows/carbon-badge.yml)
[![Release](https://img.shields.io/github/v/release/fabiocicerchia/sqlite-litestream)](https://github.com/fabiocicerchia/sqlite-litestream/releases)

SQLite + **Litestream** streaming replication in a sidecar, with an optional
**sqlite-web** admin UI. Production SQLite with disaster recovery, no
database server to run.

## Install

```sh
docker pull ghcr.io/fabiocicerchia/sqlite-litestream:latest
```

Or use the install script:

```sh
curl -fsSL https://raw.githubusercontent.com/fabiocicerchia/sqlite-litestream/main/install.sh | bash
```

## Modes

| Command (`args`) | Behaviour                                     |
| ---------------- | --------------------------------------------- |
| `replicate`      | restore if missing, then replicate (default)  |
| `restore`        | force-restore `DB_PATH`, then exit            |
| `web`            | sqlite-web UI on `:8081` (read-only unless `WEB_WRITE=true`) |

## Documentation

Full docs live in [`docs/`](docs/) (also published via mkdocs). Start with
[Getting Started](docs/getting-started.md) and the
[Architecture](docs/architecture.md) overview.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). By participating you agree to the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Found a vulnerability? See [SECURITY.md](SECURITY.md) — please don't open a
public issue.

## Support

Need help implementing this? [Get in touch](https://fabiocicerchia.it/contact).

## License

[Apache 2.0](LICENSE) © Fabio Cicerchia. Litestream and sqlite-web keep their
own upstream licenses.
