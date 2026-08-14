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

## Encryption at rest

Litestream can encrypt each replica client-side with an
[age](https://age-encryption.org) keypair, so only ciphertext leaves the
container. Recipients (the public key) encrypt on `replicate`; identities (the
secret key) decrypt on `restore`.

Generate a keypair:

```sh
age-keygen -o age.key          # prints the "age1..." public key to stderr
```

Replicate encrypted (`LITESTREAM_AGE_RECIPIENTS` is the `age1...` public key):

```sh
docker run --rm \
  -e DB_PATH=/data/app.db \
  -e REPLICA_URL=s3://my-bucket/app-db \
  -e LITESTREAM_AGE_RECIPIENTS=age1qz... \
  -v "$PWD/data:/data" \
  ghcr.io/fabiocicerchia/sqlite-litestream
```

Restore (needs the identity secret key — this is all a cold start requires):

```sh
docker run --rm \
  -e DB_PATH=/data/app.db \
  -e REPLICA_URL=s3://my-bucket/app-db \
  -e LITESTREAM_AGE_IDENTITIES="$(cat age.key)" \
  -v "$PWD/data:/data" \
  ghcr.io/fabiocicerchia/sqlite-litestream restore
```

Both vars accept multiple keys (comma/newline separated) and have a `_FILE`
variant (`LITESTREAM_AGE_RECIPIENTS_FILE` / `LITESTREAM_AGE_IDENTITIES_FILE`)
pointing at a mounted file — handy for wiring identities in from a Kubernetes
Secret. Encryption is opt-in: with no keys set the config is unchanged.

> These vars are read by the entrypoint only when it generates the config. If
> you mount your own `/etc/litestream.yml`, the generator steps aside and you
> own the `age:` block yourself.

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
