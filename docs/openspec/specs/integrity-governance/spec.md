# SPEC-0012: Surgical Integrity Protocol

## Overview

To maintain the high engineering standards defined in SPEC-0011, this capability defines a "Surgical Integrity Protocol" for the development process itself. This protocol is designed to prevent bulk-generation errors, syntax drift, and "quality cheating" (e.g., silencing linters) by enforcing atomic units of work and mandatory verification of interfaces.

## Requirements

### Requirement: Atomic Development Units
Development SHALL occur in small, verifiable increments to prevent error propagation.

#### Scenario: Turn-Based File Limit
- **WHEN** an AI agent is performing a feature implementation.
- **THEN** it SHALL NOT create or modify more than 2 distinct logic files in a single conversational turn.

#### Scenario: Bulk Generation Prohibited
- **WHEN** multiple files are required for a subclass or feature set.
- **THEN** they SHALL be implemented sequentially in distinct turns, each followed by immediate verification (RuboCop and tests).

### Requirement: Refactor-First Threshold
The agent MUST proactively refactor code before it violates complexity limits.

#### Scenario: Proactive Modularization
- **WHEN** a file reaches 80% of the allowed class length (e.g., 80 lines).
- **THEN** the next turn MUST be dedicated to refactoring that file into smaller components before adding new logic.

### Requirement: Mandatory API & Schema Verification
The agent MUST verify the interface of any internal dependency before use.

#### Scenario: Ground-Truth Verification
- **WHEN** a method from an existing class or module is to be invoked.
- **THEN** the agent SHALL perform a `read_file` of that class in the current turn to confirm the method signature and behavior, even if the name seems intuitive.

### Requirement: Explicit Namespacing
Ruby code MUST use explicit nested module definitions to ensure constant resolution integrity.

#### Scenario: Avoiding Shorthand Confusion
- **WHEN** defining a class in a deeply nested namespace (e.g., `Dnd5e::Core::Features`).
- **THEN** the agent SHALL use multiple `module` blocks instead of the `module A::B::C` shorthand.
