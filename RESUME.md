# 🛑 SESSION RETROSPECTIVE & FAILURES
In the previous sessions, the agent performed exceptionally poorly, resulting in negative progress and wasted time.
1. **Subagent Abuse:** The agent heavily relied on the `generalist` subagent to make sweeping changes. These subagents repeatedly hit turn limits, resulting in half-implemented code, broken tests, and stranded refactors.
2. **Reckless Parsing Changes:** In an attempt to fix spell slot extraction for half-casters, the agent completely broke the `ClassTableParser`. As a result, the entire `class_tables` data structure was wiped from `data/rules_cache.json`.
3. **Cascading Failures:** Because the rules cache is empty, the `SpellSlotCalculator` returns `nil` for all classes. This causes all Character Builder tests to fail (`Actual: nil`) and breaks all tactical Strategy tests because the combatants have no resources to use.
4. **Tool Inefficiency:** The agent wasted tokens and quota using raw shell commands (`grep`, `cat`) to search and read large files instead of using the optimized, built-in tools (`grep_search`, `read_file`).

## 🚨 MANDATORY NEW RULES
1. **Strict Coverage Governance:** We have implemented **ADR-0005**, establishing a strict 90% test coverage floor and a 0.5% regression limit.
   - **THE RULE:** You are **NOT ALLOWED** to delete the coverage requirement, lower the 90% floor, or gain an exception to it in CI under any circumstances without an explicit "ask-confirm-confirm" handshake with the user.
2. **No `rg` or `grep` in shell:** You must exclusively use the native `grep_search` and `read_file` tools. Do not run `grep`, `rg`, or `cat` via `run_shell_command` for file inspection.
3. **Direct Action:** Stop delegating critical, surgical test fixes to the `generalist` subagent. Handle the file modifications directly to avoid timeout interruptions.

## 💻 CURRENT TECHNICAL STATE & BLOCKERS

**Current Status:** The build is completely RED (`rake all` fails). `test:coverage:check` cannot pass because the core tests are failing.

### Blocker 1: The `ClassTableParser` is Destroyed (CRITICAL)
- **Symptom:** Running `bundle exec rake rules:build` says it parses 12 tables, but `JSON.parse(File.read("data/rules_cache.json"))` does not contain the `class_tables` key.
- **Cause:** The recent edits to `lib/dnd5e/ingest/parsers/class_table_parser.rb` likely broke the `extract_slots` or `finalize_results` logic, causing the parser to discard the tables before writing the JSON.
- **Action:** Revert or rewrite `ClassTableParser#extract_slots` so that `rules_cache.json` successfully populates the `class_tables` key. Without this, no tests will pass.

### Blocker 2: `ClassBuilderMethods` Math
- **Symptom:** Builder tests for Monk, Barbarian, and Sorcerer fail because the resource math is wrong or returning `nil`.
- **Action:** Once the parser is fixed, ensure `lib/dnd5e/builders/class_builder_methods.rb` correctly maps class names and scales resources (e.g., Monk Focus Points start at Level 2, Barbarian Rage scales 2->3 at Lv 3).

### Blocker 3: Strategy Test Initialization
- **Symptom:** Tests like `test_barbarian_uses_reckless_attack` expect `false to be truthy`.
- **Cause:** The `enemy?` checks fail because teams aren't properly initialized in the test setup.
- **Action:** In `test/dnd5e/core/test_*_strategy.rb`, ensure that `@combatant` and `@enemy` have their `.team` attribute set to a distinct `Dnd5e::Core::Team.new` instance so they recognize each other as hostile.

**Your Immediate Next Step:**
Read `lib/dnd5e/ingest/parsers/class_table_parser.rb`, fix the regex/parsing logic so `rake rules:build` actually writes the `class_tables` to the JSON, and then run `rake test`.
