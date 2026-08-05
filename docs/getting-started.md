# Getting Started

## Prerequisites

- Docker (with buildx for multi-arch builds).
- A replica destination Litestream understands: an S3-compatible bucket
  (`s3://...`) or a local path (`file:///...`).

## Run

Point the container at a database path and a replica URL:

```sh
docker run --rm \
  -e DB_PATH=/data/app.db \
  -e REPLICA_URL=s3://my-bucket/app-db \
  -v "$PWD/data:/data" \
  ghcr.io/fabiocicerchia/sqlite-litestream
```

On start in the default `replicate` mode, the entrypoint restores the database
from the replica if `DB_PATH` is missing, then replicates continuously.

## Modes

| Command (`args`) | Behaviour                                                 |
| ---------------- | --------------------------------------------------------- |
| `replicate`      | restore if missing, then replicate continuously (default) |
| `restore`        | force-restore `DB_PATH` from the replica, then exit       |
| `web`            | sqlite-web UI on `:8081` (`WEB_WRITE=true` to allow writes)|

## Next steps

- See [Architecture](architecture.md) for how config generation works.
- For multiple databases or retention policies, mount a full Litestream config
  at `/etc/litestream.yml` — the env-driven generation then steps aside.

## Development

`make build` / `make lint` / `make test` — the test does a real
write → replicate → delete → restore round-trip with a file replica.

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

See [`examples/basic`](../examples/basic) for a runnable docker compose demo.
