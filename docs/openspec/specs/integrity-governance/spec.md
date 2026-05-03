# SPEC-0012: Surgical Integrity Protocol

## Overview

To maintain the high engineering standards defined in SPEC-0011, this capability defines a "Surgical Integrity Protocol" for the development process itself. This protocol is designed to prevent bulk-generation errors, syntax drift, and "quality cheating" (e.g., silencing linters) by enforcing atomic units of work and mandatory verification of interfaces.

## Requirements

### Requirement: Concurrent & Pragmatic Development
Development SHALL balance safety with velocity, utilizing concurrency for bulk tasks.

#### Scenario: Concurrent Delegation for Bulk Tasks
- **WHEN** multiple files are required for a repetitive or additive task (e.g., creating 10 subclasses).
- **THEN** the developer or agent SHALL utilize concurrent subagents (e.g., the `generalist` subagent) or parallel shell operations to process them efficiently, rather than sequential single-file turns.

#### Scenario: Targeted Verification Over Full Gates
- **WHEN** iterating quickly within a development loop.
- **THEN** the developer SHOULD use fast, targeted unit tests (`bundle exec ruby -Ilib:test path/to/test.rb`) instead of the slow holistic `rake gate`, reserving the full gate for PRs and major milestones.

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
