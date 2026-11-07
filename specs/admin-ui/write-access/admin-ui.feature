@domain:admin-ui @area:write-access @from:sqlite-litestream/entrypoint
Feature: Browsing the database in the admin UI
  Lets an operator inspect the database in a sqlite-web UI, which stays read-only unless edits are explicitly enabled.

  Background:
    Given DB_PATH is "/data/app.db"

  @id:admin-ui.write-access.001 @rule:admin-ui.web-browser.served-on-port-8081 @inferred @source:entrypoint.sh#web
  Scenario: The admin UI serves the database on port 8081 on all interfaces
    Given a database exists at /data/app.db
    When the operator starts the container in web mode
    Then the sqlite-web UI for /data/app.db is reachable on port 8081 from outside the container

  @id:admin-ui.write-access.002 @rule:admin-ui.write-access.read-only-unless-enabled @inferred @source:entrypoint.sh#web
  Scenario Outline: The admin UI is read-only unless WEB_WRITE is exactly "true"
    Given WEB_WRITE is <web_write>
    When the operator starts the container in web mode
    Then edits through the admin UI are <edits>

    Examples:
      | web_write | edits   |
      | unset     | refused |
      | "false"   | refused |
      | "TRUE"    | refused |
      | "1"       | refused |
      | "true"    | allowed |
