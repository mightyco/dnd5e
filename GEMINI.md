# GEMINI.md - D&D 2024 Combat Simulator

## Project Overview
The **D&D 2024 Combat Simulator** is a robust, table-driven simulation engine for Dungeons & Dragons (2024 Ruleset) built in Ruby. It is designed to analyze class balance, party composition, and mathematical trade-offs through scientific simulation.

### Key Technologies
- **Ruby 3.3.x (3.3.9+)**: Primary programming language.
- **Minitest**: Testing framework.
- **RuboCop**: Linting and style enforcement.
- **Puppeteer**: UI End-to-End testing.

### Core Architecture
- **Combat Engine (`Dnd5e::Core::Combat`)**: Orchestrates the flow of encounters.
- **Modular Feature System (`FeatureManager`)**: Hook-based architecture for feats and traits.
- **Tactical AI (`Strategy`)**: Pluggable strategies for combatant behavior.
- **Builders (`CharacterBuilder`, `MonsterBuilder`)**: Fluent interfaces for construction.

## 🛠 Engineering Standards (MANDATORY)

### 1. Verification-First Architecture
The AI assistant **MUST** follow a strict **Reproduce -> Fix -> Prove** cycle.
- **Empirical Reproduction**: Every bug report MUST be reproduced with a standalone script or test case BEFORE a fix is attempted.
- **Holistic Verification**: A backend fix affecting the UI is NOT complete until a Puppeteer/E2E test confirms the UI is functional.
- **The "Liar" Gate**: Any claim of completion ("I have fixed X") without an accompanying test execution or log snippet in the *current turn* is a violation of project integrity.

### 2. Deep Context Requirement
- **UI Components**: If a UI element is being modified, the agent **MUST** perform a `read_file` of the *entire* component to understand state management before applying a `replace`.
- **Subclass Awareness**: Changes to base logic (e.g., `SimpleStrategy`) **MUST** be verified against all specialized subclasses (e.g., `BattleMasterStrategy`).

### 3. Functional Integrity > Style Metrics
- **RuboCop**: Zero offenses is the goal, but **Functional Correctness MUST NOT** be sacrificed to satisfy complexity metrics.
- **Phase-Based Priority**: During the *Execution Phase* (Act), prioritizing green tests and behavioral correctness is mandatory. Refactoring to satisfy RuboCop (e.g., method length, ABC size) should occur as a distinct "cleanup" step *after* functional verification.
- If a method exceeds 10 lines but splitting it would break logic or reduce readability, use `# rubocop:disable` with a clear justification.

## 🏁 Definition of Done (DoD)
All changes MUST meet these criteria:
1.  **Mechanical Gate**: Standalone script or unit test proves the logic change.
2.  **UI Gate**: Puppeteer test (`rake ui:e2e`) proves the dashboard/lab functionality.
3.  **CI Validation**: `bundle exec rake all` MUST be green.
4.  **Math Transparency**: Rolls and critical logic MUST be logged with full metadata.
5.  **Source Integrity**: Changes must be staged and committed after successful verification (unless specifically requested otherwise).

## 📈 Continuous Feedback & Scoring
- **Automated Logging**: Whenever a command fails, the user expresses dissatisfaction (e.g., swearing, complaints), or you are asked to redo a task that should have been correct, you MUST immediately log the event.
- **Log Location**: Append to `/Users/chuckmcintyre/src/dnd5e/.gemini/feedback_log.md`.
- **Non-Interactive Mandate**: You MUST verify non-interactive flags (e.g., `--yes`, `-y`, `--consent`) before running any CLI tool for the first time. If unsure, run `command --help` first.
- **Execution Guardrails**: ANY ruby command expected to take more than 5 seconds MUST be wrapped in a `timeout` (e.g., `timeout 30s bundle exec ...`).
- **Token Conservation**: Prefer `grep`, `cat`, and `tail` for targeted investigation. For any file >1MB, surgical tools (`tail`, `grep`, `sed`) are **MANDATORY**. Never perform a `read_file` or `cat` on massive logs.
- **Safe Shell Syntax**: DO NOT use command substitution (`$()`, `` ` ``, `<()`) in `run_shell_command`. This triggers a security block. Use literal strings or multi-step commands instead.
- **Loop Prevention**: If a debug trace produces repetitive output, terminate the tool early. Ensure simulation loops explicitly reset transient state (TurnManager) to prevent R0 hangs.
- **Rules Integrity**: Verify mechanical claims (e.g., "OAs with a bow") against the project's SRD/Rules reference. Do not state rules as fact if they involve complex interactions or specific weapon/trait requirements.
- **Log Format**:
  ```markdown
  - [YYYY-MM-DD HH:MM] SCORE: -1 | TYPE: [FAILURE|COMPLAINT|REDO] | CONTEXT: [Brief description of what happened and why it failed]
  ```
- **Proactive Retro**: If a failure is severe or repetitive, suggest running `/retro`.

## 🛠️ Systematic Troubleshooting
If a task fails more than twice:
1.  **ACTIVATE SKILL**: `activate_skill(name: 'troubleshooter')`.
2.  **Tiered Inventory**: Maintain a live inventory in `.gemini/troubleshoot_inventory.md`.
    - **Tier 1**: Ground Truths (logs, cat, direct observation).
    - **Tier 2**: Strong Inferences.
    - **Tier 3**: Guesses (untested).
    - **Tier 4**: Falsified Hypotheses.
3.  **No Guessing**: Every change must be a verified probe or a fix rooted in Tier 1/2 data.
