# Contributing

Thanks for taking the time to contribute to sqlite-litestream!

## Development setup

You need Docker (with buildx for multi-arch), `make` and `shellcheck`.

```sh
make build   # build the image locally
make lint    # hadolint + shellcheck
make test    # build + smoke test (./test.sh)
```

## Pull requests

1. Fork and create a topic branch.
2. Make your change, keeping the existing style; add or update tests.
3. Make sure `make lint` and `make test` pass locally.
4. Add an entry under `[Unreleased]` in `CHANGELOG.md` for user-visible changes.
5. Open a PR with a clear description of the problem and the solution.

## Releases

Releases are cut by pushing a git tag (see `.github/workflows/release.yml`).
Maintainers handle this; contributors only need to update the changelog.

## License

By contributing you agree that your contributions are licensed under the MIT
License (see `LICENSE`).
