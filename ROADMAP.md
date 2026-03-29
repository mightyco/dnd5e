# D&D 5e / 2024 Rules Combat Simulator Roadmap

This document tracks the implementation of D&D combat mechanics and the scientific goals of the simulation engine.

## Scientific Goal: The 2024 Fighter Duel
Our primary scientific goal is to model and compare the **Champion** and **Battlemaster** Fighter archetypes using the 2024 Ruleset. We want to determine the exact mathematical impact of the new edition's mechanics (Weapon Masteries, Heroic Inspiration on crits, etc.) on class balance.

### Current Progress
*   **Core Engine**: Action Economy, Multi-Attack, Resources (Slots/Features), and Movement are fully functional.
*   **Tactical AI**: Intelligent kiting, self-preservation, and priority targeting implemented.
*   **Subclasses**: Full 2024 implementations for Champion and Battlemaster.
*   **Scientific Dashboard**: Interactive DPR, survival, and roll-level analysis.

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
- [x] **Champion (2024)**: Improved Critical, Heroic Inspiration on crits.
- [x] **Standardized Encounter Suite (SES)**: Boss, Pack, and Swarm scenarios.

### Phase 4: Advanced Subclasses & Masteries (Completed)
- [x] **Weapon Masteries (Complete Set)**: Vex, Topple, Nick, Cleave, Graze, Slow, Push.
- [x] **Battlemaster (2024)**: Combat Superiority, Maneuvers (Trip, Push, Menacing, Precision, Tactical Shift).
- [x] **Tactical AI**: Optimized maneuver selection logic.

### Phase 5: Dashboard & Portal Integration (Completed)
- [x] **Scientific Visualization**: DPR Chart, Survival distribution.
- [x] **Lab Runner**: UI for running and saving batch simulations.
- [x] **Roll Inspector**: Math transparency for deep result analysis.
- [x] **CI Automation**: GitHub Actions for automated testing and linting.

### Phase 6: Simulation Analysis Lab (Completed)
- [x] **Statistical Significance**: Implementing 95% Confidence Intervals for win rates.
- [x] **Delta Analysis**: Automatic comparison of DPR and survival between two runs.
- [x] **Combat Categorization**: Qualitative labeling of results (Stomp, Close, Slog).
- [x] **Unified Architecture**: Single-binary feel serving UI, Docs, and API.

### Phase 7: Automated Governance (In Progress)
- [ ] **Balance Regression Testing**: Automated CI failure if a build's DPR drops below expectations.
- [ ] **Rules Ingestion Refactoring**: Dynamic parsing of rule text into JSON models.
- [ ] **Feature Audit**: Validation of implemented features against SRD text.

---

## Future Vision
*   **Party Composition Testing**: Simulating full 4-person parties through Level 10.
*   **Multi-Classing Support**: Implementation of multi-class level scaling.

