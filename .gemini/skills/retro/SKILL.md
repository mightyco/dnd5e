---
name: retro
description: Comprehensive retrospective tool for analyzing failures and improving workflows. Use when the user says "/retro", "retro that last failure", or "retro last 5 sessions" to perform root-cause analysis or aggregate refinement.
---

# Retrospective (Retro)

## Overview
The `retro` skill provides a structured way to learn from mistakes and improve the D&D 2024 Combat Simulator's development environment. It leverages the continuous feedback log to perform either immediate root-cause analysis or long-term refinement.

## Workflow Selection
- **Immediate Retro**: "retro that last failure" or "/retro last". Focuses on the most recent negative event to identify an immediate fix.
- **Aggregate Retro**: "retro last 5 sessions" or "retro over time". Analyzes trends to suggest structural changes (Start/Stop/Continue).

## Immediate Retro Workflow
1. **Locate Last Failure**: Read the last 5 lines of `/Users/chuckmcintyre/src/dnd5e/.gemini/feedback_log.md`.
2. **Context Retrieval**: Identify the task, the command that failed, and the user's feedback.
3. **Root-Cause Analysis (RCA)**:
   - Why did the command fail? (e.g., syntax error, missing dependency, incorrect assumption).
   - Why did the agent not prevent the failure?
4. **Implementation of Fix**:
   - If it's a code bug, apply the fix.
   - If it's a workflow bug, propose an update to `GEMINI.md` or a skill.
5. **Log Resolution**: Append a "RESOLVED" note to the log entry.

## Aggregate Retro Workflow (Start/Stop/Continue)
1. **Log Analysis**: Read the latest 20-50 entries from `/Users/chuckmcintyre/src/dnd5e/.gemini/feedback_log.md`.
2. **Trend Identification**: Group failures by category (e.g., "Minitest failures", "RuboCop issues", "UI E2E flakiness").
3. **Synthesis**:
   - **START**: What new process or tool should we adopt?
   - **STOP**: What counter-productive behavior or tool should we abandon?
   - **CONTINUE**: What is working well that we should double down on?
4. **Refinement Iteration**:
   - Propose specific updates to `GEMINI.md`, `STYLE_GUIDE.md`, or existing `.skill` files.
   - Design a new script or tool if needed to prevent recurring issues.

## Scoring System
- Each logged entry has a `SCORE: -1`.
- The goal of the Retro is to move the "Project Debt" back towards zero by implementing permanent fixes.
