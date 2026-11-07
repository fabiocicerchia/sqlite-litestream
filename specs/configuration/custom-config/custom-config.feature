@domain:configuration @area:custom-config @from:sqlite-litestream/entrypoint
Feature: Bringing your own Litestream config
  Lets an operator take full control of replication by mounting a complete Litestream config instead of using environment variables.

  Background:
    Given a complete Litestream config is mounted at /etc/litestream.yml

  @id:configuration.custom-config.001 @rule:configuration.custom-config.mounted-config-wins @inferred @source:entrypoint.sh#replicate|restore
  Scenario: A mounted config is used as-is and no replica URL is needed
    Given REPLICA_URL is not set
    When the operator starts the container in replicate mode
    Then replication follows the mounted config
    And no REPLICA_URL error is shown

  @id:configuration.custom-config.002 @rule:configuration.custom-config.encryption-vars-ignored @inferred @source:entrypoint.sh#replicate|restore @questionable
  Scenario: Encryption environment variables have no effect when a config is mounted
    Given LITESTREAM_AGE_RECIPIENTS is "age1examplepublickey"
    And the mounted config has no encryption settings
    When the operator starts the container in replicate mode
    Then the replica is written unencrypted
    And no warning is shown
