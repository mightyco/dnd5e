# SPEC-0009: Visual Combat Playback (Video Game Mode)

## Overview

To transition from a data-heavy dashboard to a more intuitive "Video Game Mode," the simulator SHALL provide a visual playback tool. This tool allows users to watch combatants move and act on a 2D grid, providing immediate feedback on spatial tactics like kiting, flanking, and area-of-effect spells.

## Requirements

### Requirement: Spatial Data Ingestion

The simulation engine MUST export `(x, y)` coordinate data for all combatants at every key event (movement, attack).

#### Scenario: Position Snapshot
- **WHEN** A simulation is run.
- **THEN** The resulting JSON MUST contain the grid coordinates for every combatant at the start of each round and after every movement event.

### Requirement: 2D Grid Rendering

The UI SHALL render a 2D square grid representing the battlefield.

#### Scenario: Grid Display
- **WHEN** Viewing simulation results.
- **THEN** The user MUST see a 5-foot square grid with heroes and monsters represented as tokens.

### Requirement: Playback Controls

The UI SHALL provide controls to manage the combat animation.

#### Scenario: Animation Management
- **WHEN** In "Video Game Mode".
- **THEN** The user MUST be able to Play, Pause, Step Forward/Backward, and adjust the playback Speed.

### Requirement: Visual Event Feedback

The UI SHALL animate combat events to provide feedback.

#### Scenario: Combat Animations
- **WHEN** A combatant moves.
- **THEN** Their token MUST animate from its origin to its destination.
- **WHEN** A combatant takes damage.
- **THEN** A "Floating Combat Text" popup (e.g., "-12 HP") MUST appear over the token.

### Requirement: Static Asset Strategy

The UI SHALL use lightweight, locally generated representations for combatants.

#### Scenario: Token Representations
- **WHEN** Rendering units.
- **THEN** The system MUST use simple SVG icons or retro-style pixel art to represent different classes (e.g., Fighter, Wizard) and monsters.
