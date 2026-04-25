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

### Phase 7: Automated Governance (Completed)
- [x] **Balance Regression Testing**: Automated CI failure via `rake test:balance` if win rates or survival drop below expectations.
- [x] **Rules Ingestion Refactoring**: Enhanced parser for complex 2024 table layouts and multi-column metadata.
- [x] **Feature Audit**: Validation of implemented maneuvers and masteries against PHB/SRD text using `scripts/feature_audit.rb`.

### Phase 8: UI Test and Design Mode (Completed)
- [x] **Component Testing**: Add comprehensive Vitest and React Testing Library tests to prevent UI regressions.
- [x] **Design Validation**: Clean up the landing page starting with the Scientific Lab Runner.
- [x] **End-to-End Testing**: Continue using Puppeteer/Playwright to verify major features and flows visually.

---

## 🚀 The Path to Tactical Simulation

### Tree 1: Rules Completion (Foundational)
- [ ] **Rogue Class Integration**: Core traits (Sneak Attack, Cunning Action, Evasion).
- [ ] **Feat Selection System**: Unified interface for GWM, Sharpshooter, and Dual Wielder.
- [ ] **Wizard Subclasses**: 2024 Evoker and Abjurer implementations.
- [ ] **Multi-Classing**: Heterogeneous level scaling and resource management.
- [ ] **Party Composition**: Pre-defined 4-person party templates (Tank, Healer, DPS).

### Tree 2: Tactical Grid (The Map)
- [ ] **2D Coordinate System**: Move from 1D "distance" to a proper (X, Y) grid.
- [ ] **Terrain & Obstacles**: Implementation of difficult terrain and full/half cover.
- [ ] **Aura & Area Logic**: Grid-based resolution for Paladin auras and spell radii.
- [ ] **Opportunity Attack Zones**: True "threatened area" management.

### Tree 3: Strategy & Tactics (Grid-Aware AI)
- [ ] **Pathfinding**: A* implementation for intelligent movement around obstacles.
- [ ] **Positioning Logic**: AI should seek cover, optimize AOE clusters, and kite effectively on 2D.
- [ ] **Role-Based Behavior**: Specific AI for Defenders (staying between enemy and squishies) and Strikers (flanking).

### Tree 4: "Video Game Mode" (UI/UX)
- [ ] **Visual Combat Playback**: A 2D canvas-based renderer for viewing simulation rounds.
- [ ] **Interactive Mode**: Allow a human player to control one combatant against the AI.
- [ ] **Rich Aesthetics**: Sprites, movement animations, and floating combat text.

---

## Future Vision
*   **Scientific Benchmarking**: Using the grid to determine the "True Value" of movement speed and reach.
*   **Campaign Simulation**: Simulating a series of encounters with short/long rest resource tracking.


