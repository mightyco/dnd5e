# Design: Rules Foundations (Feats, Multi-Classing, and Parties)

## Context

The D&D 2024 simulator currently supports individual classes up to level 5, but lacks the structural flexibility for multi-classing and easy deployment of standardized adventuring parties. Existing feats are implemented as separate classes but lack a discovery mechanism for the UI.

## Goals / Non-Goals

### Goals
- Implement a `ClassLevel` structure within `Statblock` to support heterogeneous leveling.
- Update `SpellSlotCalculator` to support unified caster level rules.
- Create a `PartyRegistry` to manage standardized 4-person templates.
- Expose all feats through `FeatRegistry` for UI discoverability.

### Non-Goals
- Full implementation of all 2024 feats (only core combat feats are in scope).
- Support for complex prerequisites beyond ability score minimums.

## Decisions

### Multi-Class Statblock Storage
**Choice**: Change `@level` from an integer to a `@class_levels` hash (e.g., `{ fighter: 3, rogue: 2 }`).
**Rationale**: Allows for precise tracking of which features come from which class level while maintaining a simple derived `total_level` for proficiency.

### Unified Spell Slot Strategy
**Choice**: Create a `MultiClassSpellCalculator` that aggregates levels based on 2024 rules (Full Casters 1:1, Half Casters 1:2, etc.).
**Rationale**: Adheres to 2024 multiclassing mechanics for slot progression.

## Architecture

The `CharacterBuilder` will be refactored to allow chained class declarations. The `PartyRegistry` will act as a factory for these builders.

```mermaid
graph TD
    UI[Simulation Dashboard] --> API[/api/metadata]
    API --> FR[FeatRegistry]
    API --> PR[PartyRegistry]
    
    UI --> RUN[/api/run]
    RUN --> CB[CharacterBuilder]
    CB --> SB[Statblock]
    SB --> CL[ClassLevel Hash]
    
    CB --> FM[FeatureManager]
    FM --> Feats[Feat Classes]
```

## Risks / Trade-offs

- **Class Feature Conflicts** → Some features may overlap or conflict (e.g., Unarmored Defense from Barbarian and Monk). Mitigation: Implement precedence rules in `FeatureManager`.

## Math Transparency (D&D 2024 Project)

### Proficiency Bonus
Proficiency bonus MUST be calculated based on the sum of all class levels:
`PB = 2 + ceil((TotalLevel - 4) / 4.0)`

### Multi-Class Caster Level
`CasterLevel = Wizards + Clerics + Bards + Druids + Sorcerers + (Paladins / 2).floor + (Rangers / 2).floor + (EldritchKnights / 3).floor`

### HP Calculation
First class level provides max hit die + Con. Subsequent levels (regardless of class) provide average hit die (rounded up) + Con.
