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
#
# Optional client-side age encryption (only when the config is generated):
#   LITESTREAM_AGE_RECIPIENTS   age1... public key(s), encrypt on replicate
#   LITESTREAM_AGE_IDENTITIES   AGE-SECRET-KEY-... key(s), decrypt on restore
# Each also has a *_FILE variant pointing at a mounted file; the inline var
# wins. Recipients/identities may hold several keys (comma/newline separated).
set -eu

DB_PATH="${DB_PATH:-/data/app.db}"
CONFIG=/etc/litestream.yml
MODE="${1:-replicate}"

# Resolve one age role's key material from its inline value ($1, wins) or its
# file path ($2), then normalise: split on commas/newlines, trim each entry,
# drop blanks. Prints one key per line; empty output means "no keys set".
# The pipeline ends in `sed` (not `grep`) so it exits 0 even when empty,
# keeping `set -e` happy inside the command substitution below.
age_keys() {
  _raw=""
  if [ -n "$1" ]; then
    _raw="$1"
  elif [ -n "$2" ]; then
    [ -f "$2" ] || { echo "sqlite-litestream: age key file not found: $2" >&2; exit 1; }
    _raw="$(cat "$2")"
  fi
  printf '%s' "$_raw" \
    | tr ',' '\n' \
    | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^$/d'
}

# Emit one nested YAML list under the replica's `age:` block. $1 is the key
# (recipients|identities), $2 the normalised keys (one per line). Indentation
# is literal: the key at 10 spaces, each `- item` at 12.
emit_age_role() {
  printf '          %s:\n' "$1"
  printf '%s\n' "$2" | while IFS= read -r _key; do
    printf '            - %s\n' "$_key"
  done
}

# Only replicate/restore touch $CONFIG — web (sqlite_web) and the custom-
# command escape hatch below have nothing to do with litestream, so they
# shouldn't require REPLICA_URL either.
case "$MODE" in
  replicate|restore)
    if [ ! -f "$CONFIG" ]; then
      : "${REPLICA_URL:?REPLICA_URL is required when /etc/litestream.yml is not mounted}"
      CONFIG=/tmp/litestream.yml
      cat > "$CONFIG" <<YAML
dbs:
  - path: ${DB_PATH}
    replicas:
      - url: ${REPLICA_URL}
YAML
      # Optional client-side age encryption. Appended under the replica only
      # when keys are supplied, so the unencrypted config stays byte-identical.
      _recipients="$(age_keys "${LITESTREAM_AGE_RECIPIENTS:-}" "${LITESTREAM_AGE_RECIPIENTS_FILE:-}")"
      _identities="$(age_keys "${LITESTREAM_AGE_IDENTITIES:-}" "${LITESTREAM_AGE_IDENTITIES_FILE:-}")"
      if [ -n "$_recipients" ] || [ -n "$_identities" ]; then
        {
          printf '        age:\n'
          if [ -n "$_recipients" ]; then emit_age_role recipients "$_recipients"; fi
          if [ -n "$_identities" ]; then emit_age_role identities "$_identities"; fi
        } >> "$CONFIG"
      fi
    fi
    ;;
esac

case "$MODE" in
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
