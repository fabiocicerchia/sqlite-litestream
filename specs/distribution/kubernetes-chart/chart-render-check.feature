@domain:distribution @area:kubernetes-chart @from:chart/check
Feature: Validating the Kubernetes chart
  Gives chart maintainers a single command that confirms the Helm chart lints and renders, including its optional age-encryption settings, before it reaches operators' clusters.

  Background:
    Given the chart maintainer has Docker available to run the pinned Helm 3.16.2 tooling

  @id:distribution.kubernetes-chart.001 @rule:distribution.chart-check.default-values-render @inferred @source:chart/check.sh#helm
  Scenario: The chart passes the check when it lints and renders with its default values
    Given the chart lints without errors
    And the chart rendered with default values contains a container image
    When the chart maintainer runs the chart check
    Then the check prints "OK"
    And the check exits with status 0

  @id:distribution.kubernetes-chart.002 @rule:distribution.chart-check.render-failure-refused @inferred @source:chart/check.sh#helm
  Scenario Outline: A chart that fails to lint or render fails the check
    Given the chart has <defect>
    When the chart maintainer runs the chart check
    Then the check exits with a non-zero status
    And the check does not print "OK"

    Examples:
      | defect                                      |
      | a lint error                                |
      | a template error under default values       |
      | no container image in its default rendering |

  @id:distribution.kubernetes-chart.003 @rule:distribution.chart-check.encryption-identities-rendered @inferred @source:chart/check.sh#helm @questionable
  Scenario: With encryption on and an identities secret set, the chart must point the container at the mounted identities file
    Given age encryption is enabled in the chart values
    And the age identities come from an existing secret named "x"
    When the chart maintainer runs the chart check
    Then the check passes only if the rendered workload sets LITESTREAM_AGE_IDENTITIES_FILE
    And otherwise the check exits with a non-zero status and does not print "OK"
