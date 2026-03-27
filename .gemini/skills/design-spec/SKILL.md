---
name: design-spec
description: Create a pair of specification and design documents (OpenSpec format). Use when the user wants to formalize requirements or says "create a spec".
---

# Create an OpenSpec Specification

You are creating or updating a "paired artifact": `spec.md` (requirements) and `design.md` (architecture).

## Process

1. **Capability Name**: Determine a kebab-case name for the capability (e.g., `combat-engine`). Create `docs/openspec/specs/{capability-name}/` if it doesn't exist.
2. **Scan for Existing Specs**: Determine the next `SPEC-XXXX` number by scanning `docs/openspec/specs/`.
3. **Research**: Use `codebase_investigator` to research the existing code and any relevant ADRs.
4. **Draft the Specification**:
   - Draft `spec.md` using `references/spec-template.md`.
   - Draft `design.md` using `references/design-template.md`.
   - **IMPORTANT**: Both files MUST be kept in sync.
5. **Review Phase**:
   - **Default**: Self-review against `references/architect-review.md`.
   - **With `--review` flag**: Delegate the review of **both files** to the `generalist` sub-agent acting as an Architect.
6. **Finalize**: Write both files to the capability directory.

## Rules

- **Paired Artifact**: NEVER create or update `spec.md` without also updating `design.md`.
- **RFC 2119**: Requirements MUST use MUST, SHALL, SHOULD, etc.
- **Scenarios**: Scenarios MUST use exactly 4 hashtags (`####`) and WHEN/THEN format.
- **Math Transparency**: For D&D 2024 Simulator changes, `design.md` MUST include a "Math Transparency" section.
- **Mermaid**: `design.md` MUST include at least one architecture diagram.

## Resources

- Spec Template: [references/spec-template.md](references/spec-template.md)
- Design Template: [references/design-template.md](references/design-template.md)
- Checklist: [references/architect-review.md](references/architect-review.md)
