# SPEC-0007: Infrastructure Governance & Usability Assurance

## Overview

To prevent recurring "Connection Refused" and "Wrong Content-Type" errors, this specification introduces automated governance for the simulator's infrastructure. It ensures that the human-facing UI is always accessible and that stale or misconfigured server processes are detected and killed automatically.

## Requirements

### Requirement: Strict Route Isolation

The system SHALL explicitly separate human-facing routes from machine-facing API routes to prevent content negotiation ambiguity.

#### Scenario: Human UI Access
- **WHEN** A user navigates to `/` with a standard browser header.
- **THEN** The system MUST serve `text/html`.

#### Scenario: API Isolation
- **WHEN** An API call is made to any endpoint under `/api/`.
- **THEN** The system MUST return `application/json`.

### Requirement: Usability Assertions in Tests

Existing Sinatra tests SHALL be expanded to include "Human Usability" assertions.

#### Scenario: Browser Content Verification
- **WHEN** The `SimServerTest` runs.
- **THEN** It MUST include a test case that verifies `/` returns HTML when no `Accept` header is provided (simulating default behavior).

### Requirement: Build Artifact Guardrails

The server SHALL perform a self-check of required UI and Documentation artifacts upon startup.

#### Scenario: Missing Build Detection
- **WHEN** `rake start` is executed but `ui/dist/index.html` is missing.
- **THEN** The task MUST fail immediately with an instruction to run `rake unify:build`.

### Requirement: "Healthy UI" Process Verification

The `rake status` and `rake start` tasks SHALL verify that the running process is actually serving the UI, not just a generic "online" JSON message.

#### Scenario: Stale Process Detection
- **WHEN** `rake start` detects a process on port 4567 that does not serve the expected HTML at `/`.
- **THEN** It MUST forcefully terminate the process and restart with the current codebase.
