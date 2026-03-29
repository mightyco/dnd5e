# SPEC-0003: CI/CD GitHub Actions Workflow

## Overview

This specification defines the requirements for an automated CI/CD pipeline using GitHub Actions to ensure code quality and prevent regressions in the D&D 2024 Combat Simulator.

## Requirements

### Requirement: Automated Triggering

The CI workflow MUST be triggered automatically on every `push` to any branch and every `pull_request` targeting the `main` branch.

#### Scenario: Branch Push

- **WHEN** a developer pushes changes to any branch.
- **THEN** the CI workflow MUST start running.

#### Scenario: Pull Request Update

- **WHEN** a pull request is opened or updated targeting the `main` branch.
- **THEN** the CI workflow MUST start running.

### Requirement: Ruby Environment Consistency

The workflow MUST use the Ruby version specified in the project's `.ruby-version` file (currently 3.3.9).

### Requirement: Build Prerequisites

The workflow MUST successfully run `bundle exec rake rules:build` to initialize the rules cache before running any tests or simulations.

### Requirement: Comprehensive Validation

The workflow MUST execute `bundle exec rake all`, which includes:
- Minitest test suite (`test`)
- RuboCop linting (`lint`)
- Parallel simulation examples (`examples`)

#### Scenario: Successful Run

- **WHEN** all tests, linting, and examples pass.
- **THEN** the CI status MUST be reported as success.

#### Scenario: Failure Detection

- **WHEN** any part of the `rake all` task fails.
- **THEN** the CI status MUST be reported as failure.
