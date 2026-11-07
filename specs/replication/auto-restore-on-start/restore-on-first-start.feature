@domain:replication @area:auto-restore-on-start @from:sqlite-litestream/entrypoint
Feature: Restoring a missing database on first start
  Lets an operator bring a database back on a fresh volume by restoring it from the replica before replication starts, without losing an existing database.

  Background:
    Given REPLICA_URL is "s3://backups-example/app"
    And DB_PATH is "/data/app.db"

  @id:replication.auto-restore-on-start.001 @rule:replication.auto-restore-on-start.restore-when-missing @inferred @source:entrypoint.sh#replicate
  Scenario: A missing database is restored from the replica before replication starts
    Given no database exists at /data/app.db
    And the replica holds a copy of the database
    When the operator starts the container in replicate mode
    Then the operator sees "sqlite-litestream: /data/app.db missing, attempting restore"
    And the database at /data/app.db holds the replica's data
    And replication of /data/app.db then continues

  @id:replication.auto-restore-on-start.002 @rule:replication.auto-restore-on-start.fresh-start-without-replica @inferred @source:entrypoint.sh#replicate
  Scenario: With no replica yet, the container starts fresh instead of failing
    Given no database exists at /data/app.db
    And the replica is empty
    When the operator starts the container in replicate mode
    Then the operator sees "sqlite-litestream: /data/app.db missing, attempting restore"
    And the container keeps running and replicates /data/app.db once it is created

  @id:replication.auto-restore-on-start.003 @rule:replication.auto-restore-on-start.existing-database-kept @inferred @source:entrypoint.sh#replicate
  Scenario: An existing database is never overwritten on start
    Given a database already exists at /data/app.db
    And the replica holds an older copy
    When the operator starts the container in replicate mode
    Then no restore is attempted
    And the existing /data/app.db is replicated as it is
