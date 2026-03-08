# D&D 5e / 2024 Rules Combat Simulator Roadmap

This document tracks the implementation of D&D combat mechanics and the scientific goals of the simulation engine.

## Scientific Goal: The 2024 Fighter Duel
Our immediate priority is modeling and comparing the **Champion** and **Battlemaster** Fighter archetypes using the 2024 Ruleset. We want to verify findings similar to the [Reddit math analysis](https://www.reddit.com/r/dndnext/comments/hi5t2q/comparing_the_champion_and_battlemaster_through/), but updated for the new edition's mechanics (Weapon Masteries, Heroic Inspiration on crits, etc.).

### Current Progress
*   **Core Engine**: Action Economy, Multi-Attack, Resources (Slots/Features), and Movement are fully functional.
*   **Rules Ingestion**: Class tables and spell slots are dynamically ingested from SRD data.
*   **Advanced AI**: Kiting, self-preservation, and priority targeting implemented.

---

## Technical Roadmap

### Phase 1: Core Combat Engine (Completed)
- [x] Dice Rolling & Math Transparency (Log math: `15 + 3 = 18`)
- [x] Attack Resolution (AC, Hit Points, Critical Hits)
- [x] Turn Management (Initiative, Round-robin)
- [x] Team-based Combat & Victory Conditions

### Phase 2: Game Engine Gaps (Completed)
- [x] **Action Economy**: Tracking Actions, Bonus Actions, and Reactions.
- [x] **Resource Management**: Spell Slots and Class Feature usage limits.
- [x] **Tactical Realism**: Distance, Movement speed, and Ranged Disadvantage in 5ft.
- [x] **AOE Support**: True multi-target resolution for spells like Fireball.

### Phase 3: Subclass Implementation (Completed)
- [x] **Champion (2024)**:
    - [x] Improved Critical (19-20)
    - [x] Heroic Inspiration on critical hits
    - [x] Remarkable Athlete / Additional Fighting Style

### Phase 4: Refinement & Advanced Tactics (Current Focus)
- [ ] **Condition Refactoring**: Refactor condition indirection by adding delegation to `Character` and `Monster` to simplify state checks.
- [ ] **Battlemaster (2024)**:
    - [ ] Combat Superiority (Superiority Dice pool)
    - [ ] Maneuvers: Trip, Push, Menacing, Precision, etc.
    - [ ] Tactician features
- [ ] **Complex Conditions**: Add Incapacitated and Paralyzed conditions to support high-level play and control effects.
- [ ] **Performance Optimization**: Improve simulation execution speed for high-volume batch processing.
- [x] **Weapon Masteries**: Vex, Topple (Completed); Nick, Cleave, etc. (Pending)
- [x] **Hook-based Feature System**: Modular traits (GWM, Sneak Attack, Evasion).
- [ ] **Reaction System Expansion**: Shield spell, Uncanny Dodge, and Counterspell.

---

## Historical Findings (5e Baseline)
*   **Initiative vs AC**: Initiative dominates Levels 1-4; AC dominates Level 5+.
*   **Str vs Dex**: Naked Dexterity wins 70%; Equipped Strength (Plate) wins 60%.
*   **Offense vs Defense**: High-damage (Greatsword) archetypes generally outperform high-AC (Shield) archetypes in 1v1 attrition.

---

## Future Vision
*   **Party Composition Testing**: Simulating full 4-person parties through Level 5.
*   **Reporting**: CSV/JSON export for DPR and survival rate analysis.
*   **UI/CLI**: A more interactive way to configure and run batch experiments.

