# Contributing

Thanks for taking the time to contribute to sqlite-litestream!

## Getting started

You need Docker (with buildx for multi-arch), `make`, and `shellcheck`.

1. Fork and clone the repo.
1. Install the git hooks: `make setup` (runs gitleaks on staged changes).
1. Create a branch: `git checkout -b feat/short-description`.

```sh
make build   # build the image locally
make lint    # hadolint + shellcheck
make test    # build + smoke test (write → replicate → restore round-trip)
```

## Making changes

- Keep changes focused; one logical change per PR.
- Keep `entrypoint.sh` POSIX `sh` (no bashisms); `make lint` enforces it.
- Update `docs/` and `examples/` when behavior changes.
- Ensure the `code-quality` and `security` workflows pass.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`,
`fix:`, `docs:`, `chore:`, etc. It keeps history readable and signals the
version bump.

## Pull requests

1. Push your branch and open a PR; fill out the template and link any issues.
1. Make sure `make lint` and `make test` pass locally.
1. Be kind in review.

## Releases

Releases are cut by pushing a version tag; the `Release` workflow builds the
multi-arch image, pushes it to `ghcr.io`, and creates a GitHub Release with
auto-generated notes:

```sh
git tag v0.3.13 && git push origin v0.3.13
```

Maintainers handle this — contributors don't tag or edit release notes.

## License

By contributing you agree that your contributions are licensed under the
Apache License 2.0 (see `LICENSE`).
