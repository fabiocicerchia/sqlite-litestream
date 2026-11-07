@domain:configuration @area:simple-setup @from:sqlite-litestream/entrypoint
Feature: Setting up replication from environment variables
  Lets an operator replicate a SQLite database by setting a database path and a replica URL, without writing a Litestream config file.

  Background:
    Given no Litestream config is mounted at /etc/litestream.yml

  @id:configuration.simple-setup.001 @rule:configuration.simple-setup.replica-from-env @inferred @source:entrypoint.sh#replicate|restore
  Scenario Outline: The database at the configured path is replicated to the configured replica URL
    Given DB_PATH is <db_path>
    And REPLICA_URL is "s3://backups-example/app"
    When the operator starts the container in replicate mode
    Then the database at <effective_path> is replicated to "s3://backups-example/app"

    Examples:
      | db_path         | effective_path |
      | "/data/shop.db" | /data/shop.db  |
      | unset           | /data/app.db   |

  @id:configuration.simple-setup.002 @rule:configuration.simple-setup.replica-url-required @inferred @source:entrypoint.sh#replicate|restore
  Scenario Outline: Replication and restore are refused when no replica URL is given
    Given REPLICA_URL is not set
    When the operator starts the container in <mode> mode
    Then the container exits with a failure
    And the operator sees "REPLICA_URL is required when /etc/litestream.yml is not mounted"

    Examples:
      | mode      |
      | replicate |
      | restore   |
