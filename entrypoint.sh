#!/bin/sh
# Modes:
#   replicate (default) restore-if-missing, then continuously replicate
#   restore             force restore of DB_PATH from the replica, then exit
#   web                 sqlite-web admin UI on :8081 (read-only unless WEB_WRITE=true)
#
# Config (simple mode — generates litestream.yml for you):
#   DB_PATH      path to the SQLite db          (default /data/app.db)
#   REPLICA_URL  e.g. s3://bucket/path          (required unless config mounted)
# Or mount a full config at /etc/litestream.yml to take manual control.
set -eu

DB_PATH="${DB_PATH:-/data/app.db}"
CONFIG=/etc/litestream.yml

if [ ! -f "$CONFIG" ]; then
  : "${REPLICA_URL:?REPLICA_URL is required when /etc/litestream.yml is not mounted}"
  CONFIG=/tmp/litestream.yml
  cat > "$CONFIG" <<YAML
dbs:
  - path: ${DB_PATH}
    replicas:
      - url: ${REPLICA_URL}
YAML
fi

case "${1:-replicate}" in
  replicate)
    if [ ! -f "$DB_PATH" ]; then
      echo "sqlite-litestream: ${DB_PATH} missing, attempting restore"
      litestream restore -config "$CONFIG" -if-replica-exists "$DB_PATH"
    fi
    exec litestream replicate -config "$CONFIG" ;;
  restore)
    exec litestream restore -config "$CONFIG" "$DB_PATH" ;;
  web)
    FLAGS="--host 0.0.0.0 --port 8081"
    [ "${WEB_WRITE:-false}" = "true" ] || FLAGS="$FLAGS --read-only"
    # shellcheck disable=SC2086
    exec sqlite_web $FLAGS "$DB_PATH" ;;
  *) exec "$@" ;;
esac
