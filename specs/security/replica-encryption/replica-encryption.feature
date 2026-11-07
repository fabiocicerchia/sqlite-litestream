@domain:security @area:replica-encryption @from:sqlite-litestream/entrypoint
Feature: Encrypting replicas with age
  Lets an operator keep replicas unreadable at the storage provider by encrypting them client-side with age keys, given inline or from mounted files.

  Background:
    Given no Litestream config is mounted at /etc/litestream.yml
    And REPLICA_URL is "s3://backups-example/app"

  @id:security.replica-encryption.001 @rule:security.replica-encryption.keys-from-env @inferred @source:entrypoint.sh#age_keys
  Scenario Outline: Replicas are encrypted for every recipient and restored with any listed identity
    Given LITESTREAM_AGE_RECIPIENTS is <recipients>
    And LITESTREAM_AGE_IDENTITIES is <identities>
    When the operator starts the container in replicate mode
    Then the replica is encrypted for the recipients <recipient_list>
    And restores decrypt with the identities <identity_list>

    Examples:
      | recipients               | identities                                  | recipient_list        | identity_list                                 |
      | "age1alice"              | "AGE-SECRET-KEY-1ALICE"                     | age1alice             | AGE-SECRET-KEY-1ALICE                         |
      | "age1alice, age1bob"     | "AGE-SECRET-KEY-1ALICE"                     | age1alice and age1bob | AGE-SECRET-KEY-1ALICE                         |
      | "age1alice\n\n age1bob " | "AGE-SECRET-KEY-1ALICE,AGE-SECRET-KEY-1BOB" | age1alice and age1bob | AGE-SECRET-KEY-1ALICE and AGE-SECRET-KEY-1BOB |

  @id:security.replica-encryption.002 @rule:security.replica-encryption.inline-key-wins-over-file @inferred @source:entrypoint.sh#age_keys
  Scenario Outline: An inline key takes precedence over a key file
    Given <inline_var> is "<inline_key>"
    And <file_var> points to a mounted file holding "<file_key>"
    When the operator starts the container in replicate mode
    Then only "<inline_key>" is used
    And "<file_key>" is ignored

    Examples:
      | inline_var                | file_var                       | inline_key             | file_key                 |
      | LITESTREAM_AGE_RECIPIENTS | LITESTREAM_AGE_RECIPIENTS_FILE | age1inline             | age1fromfile             |
      | LITESTREAM_AGE_IDENTITIES | LITESTREAM_AGE_IDENTITIES_FILE | AGE-SECRET-KEY-1INLINE | AGE-SECRET-KEY-1FROMFILE |

  @id:security.replica-encryption.003 @rule:security.replica-encryption.missing-key-file-refused @inferred @source:entrypoint.sh#age_keys
  Scenario: A key file that does not exist stops the container
    Given LITESTREAM_AGE_IDENTITIES is not set
    And LITESTREAM_AGE_IDENTITIES_FILE is "/keys/age-identity.txt" and that file does not exist
    When the operator starts the container in restore mode
    Then the container exits with a failure
    And the operator sees "sqlite-litestream: age key file not found: /keys/age-identity.txt"
