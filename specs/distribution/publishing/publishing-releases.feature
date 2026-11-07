@domain:distribution @area:publishing @from:sqlite-litestream/makefile
Feature: Publishing releases
  Gives image consumers versioned and latest tags whose number matches the bundled Litestream release, on the architectures they deploy to.

  Background:
    Given the maintainer is releasing image version "0.3.13" of "fabiocicerchia/sqlite-litestream"

  @id:distribution.publishing.001 @rule:distribution.publishing.release-multi-arch-versioned-and-latest @inferred @source:Makefile#release
  Scenario: A release publishes the version tag and latest for amd64 and arm64
    Given no image for version "0.3.13" is published yet
    When the maintainer runs the release
    Then "fabiocicerchia/sqlite-litestream:0.3.13" is published for linux/amd64 and linux/arm64
    And "fabiocicerchia/sqlite-litestream:latest" points to the same multi-architecture image

  @id:distribution.publishing.002 @rule:distribution.publishing.single-arch-push-leaves-latest @inferred @source:Makefile#push @questionable
  Scenario: A single-architecture push publishes only the version tag and leaves latest untouched
    Given "fabiocicerchia/sqlite-litestream:latest" points to an earlier release
    When the maintainer pushes the single-architecture image
    Then "fabiocicerchia/sqlite-litestream:0.3.13" is published for the maintainer's own architecture only
    And "fabiocicerchia/sqlite-litestream:latest" still points to the earlier release

  @id:distribution.publishing.003 @rule:distribution.publishing.image-tag-matches-litestream-version @inferred @source:Makefile#release
  Scenario: The image version tag matches the Litestream version it bundles
    Given the release version is "0.3.13"
    When the maintainer runs the release
    Then the image tagged "0.3.13" bundles Litestream "0.3.13"
