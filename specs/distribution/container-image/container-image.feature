@domain:distribution @area:container-image @from:sqlite-litestream/dockerfile
Feature: Using the published container image
  Operators deploying the image rely on what it runs by default, how it reports health, what tools it bundles, and the metadata registries show for it.

  Background:
    Given the operator uses the sqlite-litestream image

  @id:distribution.container-image.001 @rule:distribution.image.default-command-replicate @inferred @source:Dockerfile#CMD
  Scenario: With no command given, the container starts continuous replication
    Given the operator passes no command or arguments
    When the operator starts the container
    Then the container runs in replicate mode

  @id:distribution.container-image.002 @rule:distribution.image.health-reflects-litestream-presence @inferred @source:Dockerfile#HEALTHCHECK
  Scenario: The container reports healthy whenever the Litestream binary runs, in every mode
    Given the container has been running longer than its 10-second start period
    When the container runtime checks the container's health
    Then the container is healthy as long as `litestream version` succeeds within 5 seconds
    And it becomes unhealthy only after 3 consecutive failed checks taken 30 seconds apart
    And health says nothing about whether changes are actually reaching the replica

  @id:distribution.container-image.003 @rule:distribution.image.bundled-tools @inferred @source:Dockerfile#RUN
  Scenario Outline: The image ships the SQLite shell, Litestream and sqlite-web ready to use
    Given the operator overrides the command to run a tool directly
    When the operator runs <tool> in the container
    Then <tool> is found on the path and runs

    Examples:
      | tool       |
      | sqlite3    |
      | litestream |
      | sqlite_web |

  @id:distribution.container-image.004 @rule:distribution.image.oci-metadata @inferred @source:Dockerfile#LABEL @questionable
  Scenario Outline: The image publishes its title, licence, source and version as standard metadata
    Given the image has been built with the default Litestream version
    When the operator inspects the image's labels
    Then label <label> reads "<value>"

    Examples:
      | label                                | value                                                               |
      | org.opencontainers.image.title       | sqlite-litestream                                                   |
      | org.opencontainers.image.description | SQLite + Litestream replication sidecar with optional sqlite-web UI |
      | org.opencontainers.image.version     | 0.3.13                                                              |
      | org.opencontainers.image.licenses    | Apache-2.0                                                          |
      | org.opencontainers.image.source      | https://github.com/fabiocicerchia/sqlite-litestream                 |
