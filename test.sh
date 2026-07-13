#!/usr/bin/env sh
# Integration test: write → replicate to a file replica → delete → restore.
set -eu
IMAGE="${1:?usage: test.sh <image:tag>}"
docker run --rm --entrypoint sh "$IMAGE" -c '
  set -e
  mkdir -p /tmp/data /tmp/replica
  export DB_PATH=/tmp/data/app.db REPLICA_URL=file:///tmp/replica
  sqlite3 "$DB_PATH" "CREATE TABLE t(v); INSERT INTO t VALUES (42);"
  entrypoint.sh replicate & LS=$!
  sleep 3; kill $LS; wait $LS 2>/dev/null || true
  rm -f /tmp/data/app.db*
  entrypoint.sh restore
  [ "$(sqlite3 "$DB_PATH" "SELECT v FROM t;")" = "42" ] && echo ROUNDTRIP-OK
' | grep -q ROUNDTRIP-OK || { echo FAIL >&2; exit 1; }
echo PASS
