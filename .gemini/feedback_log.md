# Continuous Feedback Log
This file tracks command failures, user dissatisfaction, and task redos to enable systematic retrospectives.

---
- [2026-05-02 10:29] SCORE: -1 | TYPE: FAILURE | CONTEXT: 'gemini skills install' triggered an interactive prompt (Y/n) which required user intervention. I should have used a non-interactive flag if available.
  - RESOLVED: Added 'Non-Interactive Mandate' to GEMINI.md to ensure --help check before execution.
- [2026-05-02 11:15] SCORE: -5 | TYPE: AGGREGATE_RETRO | CONTEXT: Completed analysis of last 5 sessions. Identified buckets: Environment Parity, Data Integrity, and Architectural Rigidity. Refinement plan executed (GEMINI.md update, RuleRepository path check, rules.rake guardrails verified).
- [2026-05-02 10:39] SCORE: -1 | TYPE: FAILURE | CONTEXT: Incorrect RCA for benchmark hang. The benchmark is timing out due to infinite regressions/loops in combat logic. I failed to use timeouts or parallel guards.
  - RESOLVED: Execution Guardrails (timeout) and State Hygiene mandates added.
- [2026-05-02 11:14] SCORE: -1 | TYPE: FAILURE | CONTEXT: Incorrect implementation/statement regarding Opportunity Attacks. I claimed/implemented OAs with a Longbow, which is invalid under D&D rules (OAs require a melee weapon/reach).
  - RESOLVED: Rules Integrity mandate added to GEMINI.md.
- [2026-05-02 17:01] SCORE: -1 | TYPE: FAILURE | CONTEXT: Critical performance regression/hang in Ranger comparison. I sat for 3 minutes without output. I failed to use a local timeout guard for the ruby command.
  - RESOLVED: Execution Guardrails (timeout) now mandatory.
- [2026-05-02 17:07] SCORE: -1 | TYPE: FAILURE | CONTEXT: Introduced an infinite loop in Combat#run_rounds. The loop failed to increment the round counter because TurnManager state was not being reset, causing the simulation to hang at R0 indefinitely.
  - RESOLVED: State Hygiene mandate ensures TurnManager reset in every loop.
- [2026-05-02 18:30] SCORE: -10 | TYPE: AGGREGATE_RETRO | CONTEXT: Session slowness and token waste. RCA: Missing execution timeouts, rule halluncinations, and loop-within-loop debugging. RESOLVED: Added Execution Guardrails and Token Conservation mandates to GEMINI.md.
- [2026-05-03 06:24] SCORE: -3 | TYPE: FAILURE | CONTEXT: Wasted time on slow gate check, failed to use TDD for UI, and relied on insufficient E2E tests. UI issues: Builder unchanged in Custom Lab, Battle playback broken due to 100ft distance.
- [2026-05-03 17:15] SCORE: -10 | TYPE: FAILURE | CONTEXT: Stalled for 10+ minutes reading a massive jsonl file (session log) without setting limits or using surgical tools. Violated token conservation and efficiency mandates.
  - RESOLVED: Updated GEMINI.md with Mandatory Surgical Tools for files >1MB.
- [2026-05-03 19:49] SCORE: -1 | TYPE: FAILURE | CONTEXT: User cancelled request after extensive inconclusive diagnostics on benchmark slowness and feature integration.
  - RESOLVED: Aggregated into Retro; added START: Surgical Log Analysis to process.
- [2026-05-03 19:56] SCORE: -1 | TYPE: FAILURE | CONTEXT: Security block triggered (Command injection detected) when attempting to use command substitution in printf for logging.
  - RESOLVED: Updated GEMINI.md with Safe Shell Syntax mandate.
- [2026-05-03 20:01] SCORE: -1 | TYPE: FAILURE | CONTEXT: Multiple session stalls leading to user cancellations during the final phase of the session.
  - RESOLVED: Root causes (stalls/security) addressed in GEMINI.md updates.
- [2026-05-03 14:15] SCORE: -1 | TYPE: COMPLAINT | CONTEXT: User reported a 23+ minute "thinking" stall. This is a severe violation of efficiency and token conservation mandates. RCA: Accumulated tool-call chain and heavy internal processing without yielding control.
