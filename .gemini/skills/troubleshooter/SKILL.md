---
name: troubleshooter
description: Systematic troubleshooting and root-cause analysis. Use when a task fails repeatedly, a build doesn't reflect changes, or an unexpected "stale" state persists to avoid repetitive loops.
---

# Troubleshooting Skill

Use this skill when you are stuck in a loop or when empirical evidence (like a build timestamp) contradicts your assumptions.

## Procedural Framework

### 1. Lock the Source
Stop making "random" or "guess-based" changes to the target code. If a change didn't work the first time, repeating it with a different variable name is a failure of reasoning.

### 2. Pipeline Trace
Verify the integrity of every link in the execution chain:
- **Disk**: Is the file actually saved? (`cat` the file)
- **Compiler/Builder**: Does the tool see the change? (Introduce a syntax error to prove it's reading the file)
- **Artifact**: Is the output file updated? (Check the hash or timestamp of the `dist` file)
- **Server**: Is the server serving the *latest* artifact? (`curl` the server directly)
- **Browser/Runtime**: Is the environment caching the old version? (Check the meta-version or logs in the runtime)

### 3. Differential Analysis
If `A` (Source) should result in `B` (Output) but results in `C` (Stale Output):
1. Find the **Divergence Point** (the first step where the state is not as expected).
2. Isolate that step.
3. Test a **Minimal Reproducible Case** for just that step.

### 4. Hypothesis Testing
State your hypothesis explicitly before running a tool:
- "Hypothesis: Vite is using a cache in `node_modules/.vite`."
- "Test: Delete that specific folder and rebuild."
- "Success Criteria: Build time increases to >1s and the bundle contains the new string."

## Anti-Patterns to Avoid
- **Guessing**: "Maybe if I name it `VITE_VERSION` instead of `VERSION` it will work." (Test why `VERSION` failed first!)
- **Ignoring Signals**: 100ms build time for a large project is a **signal** of caching.
- **Overwriting without Verification**: Don't use `write_file` to fix a build system issue.
