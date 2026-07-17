# sqlite-litestream

[![CI](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/code-quality.yml/badge.svg)](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/code-quality.yml)
[![Security](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/security.yml/badge.svg)](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/security.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/fabiocicerchia/sqlite-litestream/badge)](https://securityscorecards.dev/viewer/?uri=github.com/fabiocicerchia/sqlite-litestream)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Ffabiocicerchia%2Fsqlite-litestream.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Ffabiocicerchia%2Fsqlite-litestream?ref=badge_shield)
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

## Usage

Sidecar next to your app (shared volume):

```yaml
containers:
  - name: app
    volumeMounts: [{ name: data, mountPath: /data }]
  - name: litestream
    image: ghcr.io/fabiocicerchia/sqlite-litestream
    env:
      - { name: DB_PATH,     value: /data/app.db }
      - { name: REPLICA_URL, value: "s3://my-bucket/app-db" }
    envFrom: [{ secretRef: { name: s3-credentials } }]
    volumeMounts: [{ name: data, mountPath: /data }]
```

Cold start on an empty volume restores the latest snapshot automatically
before replication begins — pod rescheduling "just works".

Advanced control (multiple DBs, retention, age limits): mount a full config
at `/etc/litestream.yml`; the env-driven generation then steps aside.

### Enabling the web UI

Add a second container off the same image in `web` mode, sharing the data
volume with the `litestream` container above — it only needs `DB_PATH`, not
`REPLICA_URL`:

```yaml
containers:
  - name: litestream
    image: ghcr.io/fabiocicerchia/sqlite-litestream
    args: ["replicate"]
    env:
      - { name: DB_PATH,     value: /data/app.db }
      - { name: REPLICA_URL, value: "s3://my-bucket/app-db" }
    volumeMounts: [{ name: data, mountPath: /data }]
  - name: web
    image: ghcr.io/fabiocicerchia/sqlite-litestream
    args: ["web"]
    env:
      - { name: DB_PATH, value: /data/app.db }
    ports: [{ containerPort: 8081 }]
    volumeMounts: [{ name: data, mountPath: /data }]
```

Read-only by default; set `WEB_WRITE=true` on the `web` container to allow
edits. It's an extra container to opt into, not something the `litestream`
container runs on its own — keep it off in prod if you don't need it, since
`sqlite-web` is a development-grade Flask server, not hardened for exposure
beyond a `kubectl port-forward`/trusted-network tunnel.

See [`examples/basic`](examples/basic) for a runnable docker compose demo.

## Documentation

Full docs live in [`docs/`](docs/) (also published via mkdocs). Start with
[Getting Started](docs/getting-started.md) and the
[Architecture](docs/architecture.md) overview.

## Development

`make build` / `make lint` / `make test` — the test does a real
write → replicate → delete → restore round-trip with a file replica.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). By participating you agree to the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Found a vulnerability? See [SECURITY.md](SECURITY.md) — please don't open a
public issue.

## License

[Apache 2.0](LICENSE) © Fabio Cicerchia. Litestream and sqlite-web keep their
own upstream licenses.
