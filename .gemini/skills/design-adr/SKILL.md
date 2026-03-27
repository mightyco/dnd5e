---
name: design-adr
description: Create a new Architecture Decision Record (ADR) using the MADR format. Use when the user wants to document an architectural choice or says "create an ADR".
---

# Create an Architecture Decision Record (ADR)

You are creating a new ADR in the MADR (Markdown Architectural Decision Records) format.

## Process

1. **Scan for Existing ADRs**: Look in `docs/adrs/` for files matching `ADR-XXXX-*.md`. Determine the next sequential number (e.g., `ADR-0005`). Create `docs/adrs/` if it doesn't exist.
2. **Understand the Decision**: If the user hasn't provided enough context, use `ask_user` to clarify the decision's core problem, drivers, and considered options.
3. **Research**: Use `codebase_investigator` to understand the current architecture and how the decision affects existing components.
4. **Draft the ADR**: Use the `references/madr-template.md` to draft the ADR.
5. **Review Phase**:
   - **Default**: Self-review against the `references/architect-review.md` checklist.
   - **With `--review` flag**: Delegate the review to the `generalist` sub-agent. Provide the draft ADR and the `references/architect-review.md` checklist to the generalist.
6. **Finalize**: Write the ADR to `docs/adrs/ADR-XXXX-short-title.md`.

## Rules

- ADR numbers MUST be sequential and zero-padded to 4 digits.
- Every ADR MUST include at least one Mermaid diagram.
- **Math Transparency**: For D&D 2024 Simulator changes, the ADR MUST explain the mathematical impact of the decision on combat statistics.
- Status starts as `proposed`.

## Resources

- Template: [references/madr-template.md](references/madr-template.md)
- Checklist: [references/architect-review.md](references/architect-review.md)
