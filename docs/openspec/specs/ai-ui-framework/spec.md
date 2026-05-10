# SPEC-0011: AI-Centric UI Framework

## Overview

The AI-Centric UI Framework is a declarative, schema-driven architecture designed to minimize state desync and maximize machine-readability. It transitions the UI from a set of hardcoded React components into a dynamic engine that interprets "Intent" defined in a central Schema Registry. This allows AI agents to safely modify the UI surface without breaking core application state or layout.

## Requirements

### Requirement: Universal Schema Coverage

The UI SHALL be driven by a central JSON schema for all character-related inputs, including Abilities, Feats, Equipment, and Class-specific features.

#### Scenario: AI Adds New Mechanic
- **WHEN** an AI agent adds a new field to `ui_schema.json`.
- **THEN** the Character Builder MUST automatically render the corresponding input in the correct section without JSX modifications.

### Requirement: Zone-Based Dynamic Slotting

The schema SHALL define "Zones" (e.g., `basic`, `stats`, `equipment`, `feats`) where dynamic fields are automatically injected.

#### Scenario: Field Reordering
- **WHEN** the `zone` property of a field is changed in the schema.
- **THEN** the UI MUST relocate the field to the new zone on the next render.

### Requirement: Intent Confirmation (Propose -> Verify)

The system SHALL require an explicit confirmation step before launching critical simulations, displaying a "Simulation Intent Manifest" (JSON).

#### Scenario: AI Proposes Simulation
- **WHEN** the "Launch" button is clicked.
- **THEN** the UI MUST display a modal showing the exact JSON payload to be sent to the backend for final verification.

### Requirement: Visual Polish & "Modern Scientific" Aesthetic

The UI SHALL utilize platform-native primitives and consistent design tokens to feel "modern, alive, and polished" as per project mandates.

#### Scenario: Team Identity
- **WHEN** combatants are assigned to teams.
- **THEN** the UI MUST use distinct, accessible color tokens (e.g., `--team-a-primary`) across both the lab and playback views.

### Requirement: Automated Observability (Machine-Readable Surface)

Every schema-driven element MUST automatically generate a unique `data-testid` based on its name.

#### Scenario: E2E Verification
- **WHEN** a new field is added via schema.
- **THEN** a Puppeteer script MUST be able to target it immediately using `[data-testid="char-builder-{field_name}"]`.
