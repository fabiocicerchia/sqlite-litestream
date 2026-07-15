# Basic Example

What it shows: continuous replication of a SQLite database to a local **file**
replica (a drop-in stand-in for an S3 bucket), plus automatic restore on a
cold start.

## Run

```sh
docker compose up -d

# create a table and a row inside the running sidecar
docker compose exec litestream \
  sqlite3 /data/app.db "CREATE TABLE t(v); INSERT INTO t VALUES (42);"

# litestream streams it to the file replica; now simulate losing the volume
docker compose down
docker volume rm basic_data

# bring it back — the entrypoint restores from the replica before replicating
docker compose up -d
docker compose exec litestream sqlite3 /data/app.db "SELECT v FROM t;"  # -> 42
```

## Clean up

```sh
docker compose down -v
```
