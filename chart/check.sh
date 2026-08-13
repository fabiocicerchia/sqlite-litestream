#!/usr/bin/env sh
# Renders the chart with default values. Fails on any template error.
set -e
cd "$(dirname "$0")"
helm() { docker run --rm -v "$PWD:/c" -w /c alpine/helm:3.16.2 "$@"; }
helm lint .
helm template t . | grep -q 'image:'
# Guard the optional age-encryption template branches (env + secret volume).
helm template t . --set age.enabled=true --set age.identities.existingSecret=x \
  | grep -q 'LITESTREAM_AGE_IDENTITIES_FILE'
echo OK
