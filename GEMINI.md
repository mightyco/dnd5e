# GEMINI.md - D&D 2024 Combat Simulator

## Project Overview
The **D&D 2024 Combat Simulator** is a robust, table-driven simulation engine for Dungeons & Dragons (2024 Ruleset) built in Ruby. It is designed to analyze class balance, party composition, and mathematical trade-offs through scientific simulation.

### Key Technologies
- **Ruby 3.3.x**: Primary programming language.
- **Minitest**: Testing framework.
- **RuboCop**: Linting and style enforcement.
- **pdf-reader**: For rule extraction from source PDFs.

### Core Architecture
- **Combat Engine (`Dnd5e::Core::Combat`)**: Orchestrates the flow of encounters, managing rounds, turns, and initiative.
- **Modular Feature System (`FeatureManager`)**: A hook-based architecture for implementing feats (e.g., GWM, Sharpshooter) and class traits (e.g., Sneak Attack) without bloating the core logic.
- **Tactical AI (`Strategy`)**: Pluggable strategies for combatant behavior, including kiting, AOE preservation, and priority targeting.
- **Builders (`CharacterBuilder`, `MonsterBuilder`)**: Fluent interfaces for constructing complex combatants and their equipment.
- **Rules Ingestion**: Dynamic extraction of class tables and spell slots from text references in `srd_reference/`.

## Building and Running

### Prerequisites
- Ruby 3.3.x
- Bundler

### Key Commands
- `bundle install`: Install dependencies.
- `bundle exec rake rules:build`: Ingest rules from reference files.
- `bundle exec rake test`: Run the full test suite.
- `bundle exec rake lint`: Run RuboCop linter.
- `bundle exec rake all`: Run tests, linting, and verify all examples.
- `ruby examples/example_science_class_balance.rb`: Run a specific simulation experiment.

## Development Conventions

### Strict Style Guide (MANDATORY)
To ensure consistency and minimize linting overhead, adhere to these rules during generation:

1. **Frozen String Literals**: Every Ruby file must start with `# frozen_string_literal: true`.
2. **Quote Style**: Use single quotes `'string'` by default; use double quotes `"string"` only for interpolation.
3. **Method Design**:
    - Max 10 lines per method.
    - Max 100 lines per class (where possible).
    - Use keyword arguments (`**options`) for methods with more than 3 parameters.
4. **Naming**: Methods returning booleans MUST end in `?` (e.g., `alive?`).
5. **Testing (Minitest)**:
    - Use `assert_predicate object, :method?` instead of `assert object.method?`.
    - Use `refute_predicate object, :method?` instead of `refute object.method?`.

### Documentation
- All public classes and methods should have RDoc/YARD-style comments explaining parameters and return values.
- Use the **Math Transparency** principle: Ensure rolls and critical logic are logged with full metadata for debugging and validation.

### Rules Management & Ignored Files
- **Research Policy**: Files and directories listed in `.gitignore` (such as `rules_reference/`) are **not off-limits** for reading. They often contain critical context (e.g., rule text, PDFs) that must be used during the research phase.
- **Commit Policy**: While these files should be read for information, they must **never** be staged or committed to the repository.
- **Tooling**: When searching for rules or context, use tools with `no_ignore: true` or `respect_git_ignore: false` to ensure ignored reference material is included in the search.

### Validation & Quality Standards
- **Strict Ruby Style**: Adhere to the rules in [STYLE_GUIDE.md](STYLE_GUIDE.md). This guide captures complexity, naming, and formatting rules derived from project linting.
- **Proactive Linting**: Run `rubocop` early and often during implementation. Do not wait for the final commit to find style or complexity violations.
- **Empirical Proof**: For balance changes or mechanical implementations, provide a simulation script (in `examples/`) that runs at least 10,000 rounds to verify expected mathematical outcomes.
- **Fast Development Cycle**: During development, use `FAST_SIM=true bundle exec rake all` to skip slow simulations (> 5s) and run examples in parallel.
- **Modular Design**: Even in example/demo scripts, extract setup and reporting logic into small, focused methods (< 10 lines) to satisfy complexity constraints.
- **Metadata Integrity**: Ensure all resolution objects (like `AttackResult`) carry enough metadata to support deep simulation analysis.
