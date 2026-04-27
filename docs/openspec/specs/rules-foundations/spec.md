# SPEC-0010: Rules Foundations (Feats, Multi-Classing, and Parties)

## Overview

To complete the foundational ruleset for the D&D 2024 Combat Simulator (Tree 1), the engine must support three core mechanical pillars: a unified Feat Selection system, the ability to combine class levels (Multi-Classing), and the capability to deploy standard Party Compositions. These features allow for more complex and realistic simulation scenarios.

## Requirements

### Requirement: Unified Feat Selection System
The simulator MUST provide a unified registry and interface for selecting and applying feats to characters.

#### Scenario: Selecting a Feat in the Lab
- **WHEN** a user is configuring a character in the Simulation Lab.
- **THEN** they SHOULD be able to select one or more feats (e.g., Great Weapon Master, Sharpshooter) from a predefined list.

#### Scenario: Applying Feat Hooks in Combat
- **WHEN** a character with Great Weapon Master reduces a target to 0 HP.
- **THEN** the engine MUST correctly trigger the bonus action attack hook defined in the feat.

### Requirement: Multi-Classing Support
The `Statblock` and `CharacterBuilder` MUST support characters with levels in multiple classes.

#### Scenario: Multi-Class Level Aggregation
- **WHEN** a character is built as a Fighter 3 / Rogue 2.
- **THEN** their total level MUST be 5, and their Proficiency Bonus MUST be +3.

#### Scenario: Multi-Class Spell Slot Calculation
- **WHEN** a character has levels in multiple spellcasting classes (e.g., Cleric 2 / Wizard 1).
- **THEN** the engine MUST calculate spell slots using the D&D 2024 Multi-Classing table (Total Caster Level = 3).

### Requirement: Pre-defined Party Compositions
The simulator SHALL provide templates for common 4-person party archetypes to facilitate rapid balance testing.

#### Scenario: Loading a Balanced Party
- **WHEN** a user selects "The Classic Four" template in the UI.
- **THEN** the simulator MUST populate Team A with a Paladin (Tank), Cleric (Healer), Wizard (AOE), and Rogue (DPS).

#### Scenario: Scientific Party Comparison
- **WHEN** a user runs a simulation of Party A vs Party B.
- **THEN** the results MUST include aggregate performance metrics for the entire party as well as individual contribution.
