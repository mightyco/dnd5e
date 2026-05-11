# UI Capability Audit & Gap Report - 2026-05-10

## 1. Current State Assessment
We have implemented a **Level 3 AI-Centric UI Framework** (Declarative Schema), but we have failed to implement the **Verification Layer**. This has resulted in several regressions:
- **AC Data Gap**: Snapshots contain AC, but the initial render or intermediate state-sync in `CombatPlayback.tsx` is likely stripping it or not receiving it.
- **Mastery Logging Silence**: Mastery events are emitted but not properly rendered or filtered in the React component's event loop.
- **Design Blindness**: The agent (me) is unable to detect visual errors or data gaps without user reports.

## 2. Capability Gaps (Why I'm Failing)
- **Gap A: State Mirroring**: I cannot "see" the exact JSON the React app holds in its state.
- **Gap B: Deep E2E**: Our E2E tests only check for high-level presence, not data integrity (e.g., checking if AC is a number or '?').
- **Gap C: Protocol Enforcement**: My "Definition of Done" allows me to claim success without providing a "Trace of Proof."

## 3. Level 4 Design: Autonomous Verification Engine

### Requirement: The UI Prober Tool
I need a tool (`scripts/probe_ui_state.js`) that:
1.  Launches the browser and runs a specific simulation.
2.  Dumps the **entire React state** and **selected DOM content** to a machine-readable JSON file.
3.  Compares the "As-Is" state against the "Should-Be" contract.

### Requirement: Mandatory Proof Traces
Every "Act" phase must conclude with a `Proof Block`:
- A JSON snippet from the Prober proving the fix.
- A screenshot (if authorized) with an OCR-based or DOM-based data check.

### Requirement: Unified Data Context
The `JSONCombatResultHandler` must be refactored to ensure **State Parity** across `initial_positions`, `snapshots`, and `events`. No data attribute (AC, Team, Mastery) should be optional or isolated.

## 4. Immediate Remediation Plan
1.  **Surgical Audit**: I will now write a script that performs a "Deep Data Trace" of the AC and Mastery fields.
2.  **Fix Core Mapping**: Refactor the Handler to ensure AC is globally available.
3.  **Upgrade Playback Log**: Ensure the Mastery event type is explicitly handled in the component's `useMemo` filter.
