# SPEC-0004: Combat Reporting and Modifier Accuracy

## Overview

This specification addresses critical bugs in the D&D 2024 Combat Simulator's resolution engine and improves the transparency of combat events in the UI/Logs. It ensures that all mathematical modifiers (Ability Scores + Proficiency Bonus) are correctly applied and that the lifecycle of a combatant (Turn Start, Resource Usage, Death) is explicitly reported.

## Requirements

### Requirement: Modifier Accuracy
- The simulator MUST apply both the relevant Ability Modifier AND the Proficiency Bonus to all attack rolls.
- The simulator MUST apply the relevant Ability Modifier to all damage rolls (except for off-hand attacks without the Two-Weapon Fighting style).
- The `Statblock` MUST correctly initialize ability scores from provided options or presets.

### Requirement: Enhanced Combat Logging
- The `CombatLogger` MUST report the start of each combatant's turn.
- The `CombatLogger` MUST explicitly report the usage of limited resources, specifically **Action Surge** and **Second Wind**.
- The `CombatLogger` MUST report when a combatant is defeated (reaches 0 HP).
- The `CombatLogger` SHOULD report the remaining Hit Points of a defender after a successful hit.

### Requirement: Math Transparency
- All logs MUST display the breakdown of the roll (e.g., `Roll: 18 (Raw: 13 + 3 Mod + 2 Prof) vs AC 16`).

## Scenarios

#### Scenario: Level 5 Fighter Attack Roll
WHEN a Level 5 Fighter with 16 Strength (+3) attacks a target
THEN the attack roll modifier MUST be +5 (+3 Strength + 2 Proficiency).

#### Scenario: Action Surge Reporting
WHEN a Fighter uses Action Surge to take an additional action
THEN the log MUST contain an entry indicating "Action Surge used".

#### Scenario: Combatant Defeat Reporting
WHEN a combatant's HP reaches 0
THEN the log MUST contain an entry indicating "[DEFEATED] <Name> has been defeated".
