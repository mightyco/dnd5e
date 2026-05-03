# SPEC-0013: Mutation Testing Governance

## Overview

Line coverage (SPEC-0011) ensures code is executed, but not necessarily verified. Mutation testing ensures that tests actually detect behavioral changes. This capability introduces a "Mutation Gate" that validates the effectiveness of the test suite against core mathematical logic. To prevent this computationally expensive process from slowing down active development, mutation testing is governed pragmatically.

## Requirements

### Requirement: Core Mutation Verification
Core mathematical modules SHOULD pass a mutation threshold to ensure logic is fully verified.

#### Scenario: Targeted Mutation Scope
- **WHEN** running mutation tests.
- **THEN** the system SHALL target `Dnd5e::Core::AttackResolver`, `Dnd5e::Core::StatblockMechanics`, and `Dnd5e::Core::Dice`.

#### Scenario: Mutation Survival Failure
- **WHEN** a mutant survives in a targeted audit (i.e., code was changed but tests still pass).
- **THEN** the CI system or developer SHOULD report the surviving mutant, and add assertions to kill it.

### Requirement: Targeted & Asynchronous Mutation
Mutation testing is computationally expensive and MUST NOT block the rapid iteration loop.

#### Scenario: Targeted Method Mutation
- **WHEN** a developer is verifying a specific, highly critical mathematical change.
- **THEN** they SHALL target mutation testing *only* at the specific method being modified (e.g., `bundle exec mutant run Dnd5e::Core::Dice#total`) rather than the entire namespace, to ensure execution finishes rapidly.

#### Scenario: Asynchronous CI Mutation
- **WHEN** evaluating overall suite quality.
- **THEN** full-namespace mutation testing SHALL be relegated to an asynchronous CI process (e.g., nightly builds) rather than a local pre-commit hook or active development gate.

### Requirement: Automated Mutation Rake Task
The project MUST provide a simple interface for running mutation tests.

#### Scenario: Quality Mutation Task
- **WHEN** a developer runs `bundle exec rake quality:mutate`.
- **THEN** the system SHALL execute the `mutant` tool against the core namespaces and output a summary of kills vs. survivals.

