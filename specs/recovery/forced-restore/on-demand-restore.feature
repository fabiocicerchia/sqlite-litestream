@domain:recovery @area:forced-restore @from:sqlite-litestream/entrypoint
Feature: Restoring the database on demand
  Lets an operator recover the database from the replica in a single run, without starting replication.

  @id:recovery.forced-restore.001 @rule:recovery.forced-restore.restore-then-exit @inferred @source:entrypoint.sh#restore @questionable
  Scenario: Restore mode recovers the database from the replica and exits
    Given REPLICA_URL is "s3://backups-example/app"
    And the replica holds a copy of the database
    And no database exists at /data/app.db
    When the operator starts the container in restore mode
    Then the database at /data/app.db holds the replica's data
    And the container exits without starting replication
