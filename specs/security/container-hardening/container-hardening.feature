@domain:security @area:container-hardening @from:sqlite-litestream/dockerfile
Feature: Running the sidecar safely
  Operators running the replication sidecar next to production data need it to run without root, stop cleanly when told to, and contain only components that can be verified.

  Background:
    Given the operator runs the sqlite-litestream image

  @id:security.container-hardening.001 @rule:security.container.runs-as-unprivileged-user @inferred @source:Dockerfile#USER
  Scenario: The sidecar runs as an unprivileged user, not root
    Given no user override is supplied at run time
    When the operator starts the container
    Then every process in the container runs as user id 10001
    And no process in the container runs as root

  @id:security.container-hardening.002 @rule:security.container.clean-shutdown-under-init @inferred @source:Dockerfile#ENTRYPOINT
  Scenario: Stopping the container shuts the sidecar down cleanly
    Given the sidecar is running in any mode
    When the orchestrator asks the container to stop
    Then the running tool receives the stop signal and exits
    And the container stops without waiting for the forced-kill timeout
    And no orphaned processes are left behind

  @id:security.container-hardening.003 @rule:security.container.admin-ui-packages-hash-verified @inferred @source:Dockerfile#RUN
  Scenario: The admin UI's packages are installed only when their locked hashes match
    Given the admin UI's Python packages are locked to exact versions with sha256 hashes
    When the maintainer builds the image and one of those packages does not match its locked hash
    Then the image build fails
    And no image containing the mismatched package is produced

  @id:security.container-hardening.004 @rule:security.container.litestream-binary-integrity @inferred @source:Dockerfile#fetch @questionable
  Scenario: The bundled Litestream binary is accepted without checking it against a known checksum
    Given the Litestream release version is pinned
    When the maintainer builds the image
    Then the Litestream archive for that version is downloaded over HTTPS from its GitHub release
    And it is unpacked into the image without any checksum or signature check
