@domain:distribution @area:installer @from:sqlite-litestream/install
Feature: Installing sqlite-litestream with one command
  Lets an operator fetch the latest published sqlite-litestream image with a single piped command and find out where to read how to configure it.

  Background:
    Given the sqlite-litestream image is published at ghcr.io/fabiocicerchia/sqlite-litestream with the tag latest

  @id:distribution.installer.001 @rule:distribution.installer.pulls-latest-published-image @inferred @source:install.sh#IMAGE @questionable
  Scenario: The installer fetches the latest published image and points to the documentation
    Given Docker is installed and the registry is reachable
    When the operator runs the one-line installer
    Then the image ghcr.io/fabiocicerchia/sqlite-litestream:latest is present locally
    And the operator sees "sqlite-litestream ready."
    And the operator sees "See README for environment variables and usage." followed by https://github.com/fabiocicerchia/sqlite-litestream
    And the installer exits with status 0

  @id:distribution.installer.002 @rule:distribution.installer.no-ready-claim-on-failed-pull @inferred @source:install.sh#IMAGE
  Scenario Outline: A failed download stops the installer without claiming it is ready
    Given <condition>
    When the operator runs the one-line installer
    Then the operator sees the error reported by Docker or the shell
    And the operator does not see "sqlite-litestream ready."
    And the installer exits with a non-zero status

    Examples:
      | condition                              |
      | Docker is not installed                |
      | the registry ghcr.io cannot be reached |
