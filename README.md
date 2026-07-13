# sqlite-litestream

[![CI](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/ci.yml/badge.svg)](https://github.com/fabiocicerchia/sqlite-litestream/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

SQLite + **Litestream** streaming replication in a sidecar, with an optional
**sqlite-web** admin UI. Production SQLite with disaster recovery, no
database server to run.

## Modes

| Command (`args`) | Behaviour |
|---|---|
| `replicate` (default) | restore the DB if missing, then replicate continuously |
| `restore` | force-restore `DB_PATH` from the replica, then exit |
| `web` | sqlite-web UI on `:8081` (read-only unless `WEB_WRITE=true`) |

## Usage

Sidecar next to your app (shared volume):

```yaml
containers:
  - name: app
    volumeMounts: [{ name: data, mountPath: /data }]
  - name: litestream
    image: fabiocicerchia/sqlite-litestream
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

## Development

`make build` / `make lint` / `make test` — the test does a real
write → replicate → delete → restore round-trip with a file replica.

## License

MIT — see [LICENSE](LICENSE). Litestream and sqlite-web keep their own
upstream licenses.
