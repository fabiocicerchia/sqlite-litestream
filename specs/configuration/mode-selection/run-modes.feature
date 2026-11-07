@domain:configuration @area:mode-selection @from:sqlite-litestream/entrypoint
Feature: Choosing a run mode
  Lets an operator pick, with the container's first argument, whether it replicates, restores, serves the admin UI or runs any other command.

  @id:configuration.mode-selection.001 @rule:configuration.mode-selection.replicate-by-default @inferred @source:entrypoint.sh#replicate
  Scenario: Without a mode, the container replicates continuously
    Given REPLICA_URL is "s3://backups-example/app"
    And a database exists at /data/app.db
    When the operator starts the container with no arguments
    Then changes to /data/app.db are streamed to "s3://backups-example/app"
    And the container keeps running until it is stopped

  @id:configuration.mode-selection.002 @rule:configuration.mode-selection.replica-settings-only-for-litestream-modes @inferred @source:entrypoint.sh#replicate|restore
  Scenario Outline: The admin UI and custom commands start without replica settings
    Given REPLICA_URL is not set
    And no Litestream config is mounted at /etc/litestream.yml
    When the operator starts the container with <arguments>
    Then <outcome>
    And no REPLICA_URL error is shown

    Examples:
      | arguments                      | outcome                                   |
      | web                            | the admin UI is served on port 8081       |
      | sqlite3 /data/app.db ".tables" | the table list of /data/app.db is printed |

  @id:configuration.mode-selection.003 @rule:configuration.mode-selection.custom-command-passthrough @inferred @source:entrypoint.sh#*
  Scenario: Any other argument is run as a command in the container
    Given a database exists at /data/app.db
    When the operator starts the container with "sqlite3 /data/app.db 'SELECT count(*) FROM orders;'"
    Then the query result is printed
    And the container exits with that command's exit status
