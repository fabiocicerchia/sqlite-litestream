# Architecture

## Overview

The image is a thin, mode-selecting wrapper around two upstream tools:

- **Litestream** — streaming replication of a live SQLite database to object
  storage (or a local path).
- **sqlite-web** — an optional browser admin UI, served only in `web` mode.

It ships no application code of its own; the logic is a single POSIX
`entrypoint.sh`.

## Components

- `Dockerfile` — multi-stage build. Stage one fetches the pinned Litestream
  release binary; the runtime stage is `python:3.14-alpine` with `sqlite`,
  `tini` (PID 1 / signal reaping), and `sqlite-web` installed. Runs as an
  unprivileged user (uid 10001).
- `entrypoint.sh` — generates `/tmp/litestream.yml` from `DB_PATH` +
  `REPLICA_URL` unless a full config is mounted at `/etc/litestream.yml`, then
  dispatches on the first argument. When `LITESTREAM_AGE_RECIPIENTS` /
  `LITESTREAM_AGE_IDENTITIES` (or their `_FILE` variants) are set, it appends an
  `age:` encryption block under the replica.

## Data flow

```
app writes ──▶ SQLite file (DB_PATH, shared volume)
                     │
                     ▼
              litestream replicate ──▶ REPLICA_URL (S3 / file)
                     ▲
     cold start ─────┘  (restore -if-replica-exists before replicating)
```

## Decisions

- **Env-driven config with an escape hatch.** The common single-database case
  needs only two env vars; power users mount a full Litestream config and the
  generator gets out of the way. Optional age encryption follows the same rule —
  key env vars are spliced into the generated config, but ignored entirely when
  a config is mounted.
- **Non-root, tini as PID 1.** Keeps the sidecar well-behaved under
  orchestrators (clean signal handling, no zombie processes).
