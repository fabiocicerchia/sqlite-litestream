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

# Encrypted round-trip: same flow, but with client-side age encryption. age-keygen
# isn't in the runtime image (Litestream links age as a library), so mint an
# ephemeral keypair in a throwaway container that adds the package. Skips cleanly
# if the package can't be fetched (offline), keeping the plaintext test as the gate.
KEYS=$(docker run --rm --user 0 --entrypoint sh "$IMAGE" -c \
  'apk add --no-cache age >/dev/null 2>&1 && age-keygen 2>/dev/null' || true)
RECIPIENT=$(printf '%s\n' "$KEYS" | sed -n 's/^# public key: //p')
IDENTITY=$(printf '%s\n' "$KEYS" | sed -n '/^AGE-SECRET-KEY-/p')
if [ -n "$RECIPIENT" ] && [ -n "$IDENTITY" ]; then
  docker run --rm --entrypoint sh \
    -e LITESTREAM_AGE_RECIPIENTS="$RECIPIENT" \
    -e LITESTREAM_AGE_IDENTITIES="$IDENTITY" \
    "$IMAGE" -c '
      set -e
      mkdir -p /tmp/data /tmp/replica
      export DB_PATH=/tmp/data/app.db REPLICA_URL=file:///tmp/replica
      sqlite3 "$DB_PATH" "CREATE TABLE t(v); INSERT INTO t VALUES (42);"
      entrypoint.sh replicate & LS=$!
      sleep 3; kill $LS; wait $LS 2>/dev/null || true
      # Prove the replica is genuinely encrypted: age binary output carries the
      # ASCII header "age-encryption.org"; a plaintext WAL would not.
      grep -ralq "age-encryption.org" /tmp/replica
      rm -f /tmp/data/app.db*
      entrypoint.sh restore
      [ "$(sqlite3 "$DB_PATH" "SELECT v FROM t;")" = "42" ] && echo ENCRYPTED-ROUNDTRIP-OK
    ' | grep -q ENCRYPTED-ROUNDTRIP-OK || { echo "FAIL (encrypted)" >&2; exit 1; }
  echo "PASS (encrypted round-trip)"
else
  echo "SKIP (encrypted round-trip: age-keygen unavailable, likely offline)"
fi

echo PASS
