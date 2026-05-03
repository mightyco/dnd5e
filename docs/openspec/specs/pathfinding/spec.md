# SPEC-0014: A* Pathfinding and Grid Navigation

## Overview

The D&D 2024 Simulator currently uses a 2D coordinate system, but AI movement is simplistic (direct line-of-sight). To support complex combat scenarios with terrain and obstacles, the simulator requires a robust pathfinding engine. This capability introduces an A* implementation to calculate optimal paths while respecting movement costs and grid constraints.

## Requirements

### Requirement: Optimal Path Calculation
The system MUST calculate the shortest path between two points on the grid.

#### Scenario: Unobstructed Movement
- **WHEN** an attacker moves toward a target on an empty grid.
- **THEN** the A* engine SHALL return a direct sequence of coordinates equal to the Manhattan distance.

#### Scenario: Obstacle Avoidance
- **WHEN** a direct path is blocked by an obstacle (e.g., a wall or another combatant).
- **THEN** the A* engine SHALL calculate an optimal path around the obstacle, ensuring no diagonal cutting through corners of solid blocks.

### Requirement: Movement Cost Awareness
The system MUST account for different terrain types.

#### Scenario: Difficult Terrain
- **WHEN** a path includes "difficult terrain" squares.
- **THEN** the movement cost for those squares SHALL be doubled (2 feet per 1 foot moved), and the pathfinder SHALL prefer alternate routes if they are cheaper.

### Requirement: Grid Constraints
The system MUST respect combatant size and reach.

#### Scenario: Large Combatant Navigation
- **WHEN** a Large (2x2) combatant moves.
- **THEN** the pathfinder SHALL ensure all 4 squares of the combatant's footprint remain valid and unobstructed throughout the path.
