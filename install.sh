#!/usr/bin/env bash
set -euo pipefail
# One-line installer for sqlite-litestream
# Usage: curl -fsSL https://raw.githubusercontent.com/fabiocicerchia/sqlite-litestream/main/install.sh | bash

IMAGE="ghcr.io/fabiocicerchia/sqlite-litestream:latest"

echo "Pulling sqlite-litestream from GHCR..."
docker pull "$IMAGE"
echo ""
echo "sqlite-litestream ready."
echo "See README for environment variables and usage."
echo "  https://github.com/fabiocicerchia/sqlite-litestream"
