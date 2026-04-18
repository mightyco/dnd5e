# SPEC-0008: Tactical Grid & Spatial Simulation

## Overview

To enable meaningful tactical simulation, the D&D 2024 Combat Simulator must transition from a 1D "distance" integer to a 2D coordinate-based grid. This foundation allows for the implementation of 2024 movement rules, ranged combat dynamics, area-of-effect (AOE) spatial resolution, and tactical AI pathfinding.

## Requirements

### Requirement: 2D Coordinate System

The `Combat` engine SHALL maintain a 2D grid representing the battlefield, with combatants occupying specific coordinates.

#### Scenario: Combatant Positioning
- **WHEN** A combatant is added to an encounter.
- **THEN** They MUST be assigned a `(x, y)` coordinate on a 5-foot square grid.

#### Scenario: Distance Calculation
- **WHEN** Calculating distance between two combatants for an attack or move.
- **THEN** The system MUST use Euclidean distance or the 5e "diagonal" rule (5-5-5 or 5-10-5) as configured.

### Requirement: 3D Altitude Support

The system SHALL track a "Height" status for combatants to support flying and verticality without a full 3D XYZ pathfinding engine.

#### Scenario: Ranged Attack from Altitude
- **WHEN** A flying combatant attacks a target on the ground.
- **THEN** The range calculation MUST incorporate the altitude difference.

### Requirement: Tactical Grid Movement

Combatants SHALL move between grid squares based on their Speed, respecting obstacles and threatened zones.

#### Scenario: Movement Cost
- **WHEN** A combatant moves across the grid.
- **THEN** Each square MUST cost 5 feet of movement (10 feet if through difficult terrain).

#### Scenario: Opportunity Attack Zones
- **WHEN** A combatant leaves a square threatened by an enemy.
- **THEN** The enemy MUST be triggered to take an Opportunity Attack (unless Disengaged).

### Requirement: Area-of-Effect (AOE) Spatial Resolution

Spells and abilities with areas (Spheres, Cones, Cubes) SHALL be resolved based on grid occupancy.

#### Scenario: Fireball Resolution
- **WHEN** A Fireball is cast at a specific grid intersection.
- **THEN** Every combatant within the 20-foot radius MUST be identified for saving throws.

### Requirement: Hidden States & Perception

The system SHALL support "Hidden" status based on grid position and cover.

#### Scenario: Rogue Hiding
- **WHEN** A Rogue takes the Hide action behind full cover.
- **THEN** Their position MUST be marked as Hidden, granting Advantage on their next attack against targets unaware of them.

## Acceptance Criteria & Validation

### Requirement: Statistical Parity (Backport)

The introduction of the grid SHALL NOT significantly alter the mathematical outcomes of existing simulations when movement is disabled.

#### Scenario: Verification of Scientific Goals
- **WHEN** Running existing presets (e.g., Fighter Duel) using the 2D Grid in "Stationary Mode".
- **THEN** The win rates and DPR MUST fall within the 95% confidence interval established by the previous 1D distance system (based on 1,000 iterations).

## Phased Rollout

1.  **Phase 1: Stationary Grid**: Implement `TacticalGrid` and map 1D `distance` to fixed `(x, y)` coordinates. Existing examples MUST pass without logic changes.
2.  **Phase 2: Statistical Validation**: Run all presets 1,000 times to confirm mathematical parity.
3.  **Phase 3: Tactical Movement**: Enable 2D pathfinding and grid-aware AI strategy.
