@domain:documentation-site @area:theme-and-branding @from:stylesheets/extra
Feature: Giving the documentation its look
  Readers of the sqlite-litestream docs and splash page get one consistent, legible, self-hosted visual identity in light and dark schemes.

  Background:
    Given the documentation site and the splash page are published

  @id:docs.documentation-site.theme-and-branding.001 @rule:docs.theme.single-shared-palette @inferred @source:docs/stylesheets/extra.css#:root
  Scenario: The splash page and the docs share one accent palette
    Given the accent pair is cyan #22d3ee and indigo #6366f1
    When a reader opens the splash page and then the rendered docs
    Then the primary colour of both is indigo #6366f1
    And the interactive accent of both is cyan #22d3ee
    And primary buttons on both show a cyan-to-indigo gradient

  @id:docs.documentation-site.theme-and-branding.002 @rule:docs.theme.links-legible-per-scheme @inferred @source:docs/stylesheets/extra.css#[data-md-color-scheme="slate"]
  Scenario Outline: Links use the accent that stays readable on the current colour scheme
    Given the reader's colour scheme is <scheme>
    When the reader views a docs page
    Then links are shown in <link_colour>
    And the page background is <background>

    Examples:
      | scheme | link_colour    | background                           |
      | light  | indigo #6366f1 | the theme's default light background |
      | dark   | cyan #22d3ee   | near-black #0b0f1a                   |

  @id:docs.documentation-site.theme-and-branding.003 @rule:docs.theme.no-placeholder-logo @inferred @source:docs/stylesheets/extra.css#.md-header__button.md-logo
  Scenario: The docs show no stand-in logo while the project has none
    Given the project has no logo configured
    When a reader views the docs header and navigation
    Then no logo or generic book icon appears in the header
    And no logo appears at the top of the navigation drawer

  @id:docs.documentation-site.theme-and-branding.004 @rule:docs.privacy.no-web-fonts @inferred @source:docs/stylesheets/extra.css#:root
  Scenario: The docs render in the reader's system fonts without downloading any font
    Given the reader is offline or blocks third-party requests
    When the reader opens a docs page
    Then body text is shown in the system sans-serif font
    And code is shown in the system monospace font
    And no font is requested from any external server
