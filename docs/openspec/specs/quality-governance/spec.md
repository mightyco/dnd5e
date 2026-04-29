# SPEC-0011: Quality Governance and Automated Gates

## Overview

To prevent technical debt and behavioral regressions, the D&D 2024 Combat Simulator must enforce strict quality governance. This capability establishes automated "Gates" that block any commit or feature completion that degrades the system's architectural integrity or test coverage. This is essential for maintaining the high engineering standards required for complex 2024 rules simulation.

## Requirements

### Requirement: Zero-Offense RuboCop Standard
The codebase MUST maintain zero RuboCop offenses.

#### Scenario: Code Complexity Threshold
- **WHEN** a method exceeds 10 lines or a class exceeds 100 lines.
- **THEN** the developer SHALL refactor the code into modular helpers or mixins instead of using `rubocop:disable`.

#### Scenario: Forbidden Disables
- **WHEN** a RuboCop offense is detected.
- **THEN** the developer SHALL NOT use `# rubocop:disable` comments to silence complexity or length metrics.

### Requirement: Mandatory Coverage Floor
The project MUST enforce a minimum test coverage floor of 90.0%.

#### Scenario: Coverage Regression
- **WHEN** a new feature is added that drops overall line coverage below 90.0%.
- **THEN** the CI system SHALL fail the build, and the developer MUST add corresponding unit tests to restore the floor.

#### Scenario: One-Way Quality Ratchet
- **WHEN** coverage is improved beyond the current floor.
- **THEN** the developer SHOULD record a new baseline, effectively raising the floor for future changes.

### Requirement: The Holistic Verification Gate
A task SHALL NOT be considered complete until all verification layers pass.

#### Scenario: Full Stack Validation
- **WHEN** a backend or frontend change is made.
- **THEN** the developer MUST execute the "Holistic Gate" command: `bundle exec rake all && bundle exec rake ui:e2e && rake examples`.

#### Scenario: Fix-Forward Only
- **WHEN** a test or verification step fails.
- **THEN** the developer SHALL NOT `skip` the test or revert quality standards; the only allowed path is a "fix-forward" refactor.
