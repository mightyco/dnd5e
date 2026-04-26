# GEMINI RECOVERY PROTOCOL: Systematic Engineering Rigor

This document serves as the foundational mandate to fix the Gemini CLI's execution model. It replaces previous lax workflows with a **Verification-First** architecture.

---

## 1. DESIGN-SPEC: Verification-First Architecture (SPEC-0007)

### Goal
To eliminate "false authority" and "break-fix cycles" by ensuring every change is empirically proven at both the mechanical (Ruby) and visual (UI) levels before it is considered "Done."

### Mandatory Requirements
1.  **Empirical Reproduction**: Every bug report MUST be reproduced with a standalone script or test case BEFORE a fix is attempted.
2.  **Holistic Verification**: A fix in the backend (API/Core) that affects the frontend (UI) is NOT complete until a Puppeteer/E2E test confirms the UI is still functional.
3.  **Subclass-Aware Gating**: Changes to base logic (e.g., `SimpleStrategy`) MUST be verified against all specialized subclasses (e.g., `BattleMasterStrategy`) to prevent silent regressions.
4.  **No Narrative Authority**: The agent MUST NOT use the phrase "I have fixed" or "I have implemented" unless it can point to a passing automated test or log output provided in the *current* turn.

---

## 2. DESIGN-PLAN: The Road to Reliability

### Phase 1: Foundational Doc Rewrite
- [ ] Update `GEMINI.md` to move "Empirical Proof" from a guideline to a **Hard Mandate**.
- [ ] Update `STYLE_GUIDE.md` to clarify that **Functional Integrity > Style Metrics**. RuboCop refactoring must never happen without an integration test safety net.

### Phase 2: Tooling & Skill Fixes
- [ ] **Troubleshooter Skill**: Enhance the skill to require a "Verification Proof" section in every troubleshooting log.
- [ ] **CI Pipeline**: Ensure `rake all` is the only acceptable finality check, and it must include the `ui:e2e` task.

---

## 3. UPDATED MANDATES (To be merged into GEMINI.md)

### Security & System Integrity
- **Mandate**: Never log secrets. (Unchanged)

### Engineering Standards (NEW)
- **The 3-Turn Rule**: If a UI element is being fixed, the agent MUST perform a `read_file` of the *entire* component to understand the state management before applying a `replace`.
- **The "Liar" Gate**: Any claim of completion without an accompanying test execution or log snippet is a violation of project integrity.
- **The Subclass Checklist**: Before touching `Core::Combat` or `Strategies`, the agent MUST list all affected subclasses and plan a verification for each.

---

## 4. RETROSPECTIVE: Start, Stop, Continue

### 🟢 START
- **Mandatory E2E Gating**: Running Puppeteer tests for *every* UI-adjacent change.
- **Deep Context Reads**: Reading the full source of React components before editing to avoid wiping out logic during "surgical" replaces.
- **Mechanical Trace**: Tracing combat logs line-by-line (like the user provided) to verify specific multi-attack redirection counts.

### 🛑 STOP
- **Stop Claiming Success without Proof**: No unverified "authority."
- **Stop Silo Refactoring**: Never break class logic just to satisfy a RuboCop line-count metric.
- **Stop Ignoring UX**: A button that "clicks" but doesn't populate data is a failure.

### 🟡 CONTINUE
- **Standalone Reproduction Scripts**: Isolate complex logic in `debug_*.rb` files.
- **Rake Integration**: Keeping the entire validation suite accessible via a single command.

---

## 5. RECOVERY EXECUTION PLAN

1.  **Step 1**: Overwrite `GEMINI.md` with the new Rigor Mandates.
2.  **Step 2**: Update `troubleshooter` skill to include the "Proof of Verification" requirement.
3.  **Step 3**: Re-verify the roadmap using the **Mechanical Gate** (Subclass checks) and **UI Gate** (Puppeteer).
