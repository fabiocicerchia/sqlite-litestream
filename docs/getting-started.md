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
