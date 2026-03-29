---
name: design-plan
description: Decompose a specification (OpenSpec) into trackable issues. Use when the user wants to "plan a sprint" or says "create issues for SPEC-XXXX".
---

# Plan a Sprint (Decompose Specs into Issues)

You are decomposing a specification (`spec.md`) into actionable tasks or issues.

## Process

1. **Locate Specification**: Identify the target `spec.md` (e.g., `docs/openspec/specs/capability/spec.md`).
2. **Analyze Requirements**: Read the `spec.md` and extract each individual requirement and its associated scenarios.
3. **Draft Issues**: Group requirements into logical tasks or issues.
4. **Choose Execution Mode**:
   - **Dry Run (Default)**: Use `run_shell_command` with the `gh_issue_creator.sh` script to output the `gh` commands that *would* be run.
   - **Live Execution**: With the user's explicit consent via `ask_user`, run the `gh issue create` commands.
5. **Summarize**: Provide a list of the issues created (or planned) and their corresponding requirement IDs (e.g., SPEC-XXXX REQ 1).
6. **Closing Protocol**: Upon successful implementation and verification of a task, the agent SHALL use the `gh` CLI to close the corresponding issue with a descriptive comment.

## Rules

- Every issue MUST reference the `spec.md` it originated from.
- Each issue MUST include the "WHEN/THEN" scenarios as acceptance criteria.
- **Issue Lifecycle**: All created issues MUST be closed by the agent once implementation is verified.
- **Math Transparency**: If the requirement involves mechanical changes for the D&D 2024 Simulator, the issue MUST include a task for "Verification/Simulation" to ensure mathematical correctness.

## Resources

- Issue Script: [scripts/gh_issue_creator.sh](scripts/gh_issue_creator.sh)
