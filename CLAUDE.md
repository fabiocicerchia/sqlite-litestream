# CLAUDE.md

Guidance for Claude Code (and other AI agents) working in this repo.

## Project

`sqlite-litestream` is a Docker image that runs [Litestream](https://litestream.io)
streaming replication for a SQLite database as a sidecar, with an optional
[sqlite-web](https://github.com/coleifer/sqlite-web) admin UI. There is no
application code — the repo is a `Dockerfile` plus a POSIX `entrypoint.sh` that
selects a mode (`replicate` / `restore` / `web`) and generates a Litestream
config from `DB_PATH` + `REPLICA_URL` env vars.

## Commands

```sh
make build   # build the image locally
make lint    # hadolint (Dockerfile) + shellcheck (entrypoint.sh, test.sh)
make test    # build + smoke test: write → replicate → restore round-trip
make setup   # install the pre-commit git hooks
make help    # Show this help
make push    # Push the single-arch image
make release # Build and push the multi-arch image (:VERSION and :latest)
```

## Tooling

- `make setup` installs the pre-commit hook, and that is the whole of it.
  Don't add a `.githooks/` directory: `core.hooksPath` replaces `.git/hooks/`
  wholesale, so setting it silently stops every pre-commit hook from running.
- Hooks are pinned by commit SHA with the tag in a trailing comment. A tag can
  be moved, a SHA cannot.
- CI runs this same `.pre-commit-config.yaml` through `pre-commit/action`, so
  what passes locally is what gates the pull request.

## Conventions

- Match existing style; keep the entrypoint POSIX `sh` (no bashisms).
- Conventional Commits for messages (see CONTRIBUTING.md).
- Pin GitHub Actions to full commit SHAs and Alpine `apk` packages to versions.
- Never commit secrets; CI runs gitleaks. Keep `.env` out of git.

## Guardrails

- Don't add dependencies without a clear reason; the image stays minimal.
- Don't touch the `LICENSE` (Apache-2.0) or vendored binaries by hand.
- Ask before large refactors or destructive operations.
