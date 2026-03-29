# GEMINI.md - D&D 2024 Combat Simulator

## Project Overview
The **D&D 2024 Combat Simulator** is a robust, table-driven simulation engine for Dungeons & Dragons (2024 Ruleset) built in Ruby. It is designed to analyze class balance, party composition, and mathematical trade-offs through scientific simulation.

### Key Technologies
- **Ruby 3.3.x (3.3.9+)**: Primary programming language.
- **Minitest**: Testing framework.
- **RuboCop**: Linting and style enforcement.
- **pdf-reader**: For rule extraction from source PDFs.

### Core Architecture
- **Combat Engine (`Dnd5e::Core::Combat`)**: Orchestrates the flow of encounters, managing rounds, turns, and initiative.
- **Modular Feature System (`FeatureManager`)**: A hook-based architecture for implementing feats (e.g., GWM, Sharpshooter) and class traits (e.g., Sneak Attack) without bloating the core logic.
- **Tactical AI (`Strategy`)**: Pluggable strategies for combatant behavior, including kiting, AOE preservation, and priority targeting.
- **Builders (`CharacterBuilder`, `MonsterBuilder`)**: Fluent interfaces for constructing complex combatants and their equipment.
- **Rules Ingestion**: Dynamic extraction of class tables and spell slots from text references in `srd_reference/`.

## 🛠 Project Infrastructure

### Developer Resources
For detailed guides on rule extraction, linter configuration, and performance benchmarking, see [DEVELOPER.md](DEVELOPER.md).

### Coding Standards (MANDATORY)
The AI assistant **MUST** strictly adhere to the project's [STYLE_GUIDE.md](STYLE_GUIDE.md). Key mandates include:
- **Frozen String Literals**: Must be present in every Ruby file.
- **Complexity**: Maximum 10 lines per method and 100 lines per class (hard limit).
- **Boolean Naming**: Predicate methods must end in `?`.
- **Testing**: Use `assert_predicate` and `refute_predicate` for all boolean checks.

## Building and Running

### Prerequisites
- Ruby 3.3.x (3.3.9+)
- Bundler

### Key Commands
- `bundle install`: Install dependencies.
- `bundle exec rake rules:build`: Ingest rules from reference files (using `extract_rules.rb` for source PDF handling).
- `bundle exec rake test`: Run the full test suite.
- `bundle exec rake lint`: Run RuboCop linter.
- `bundle exec rake all`: Run tests, linting, and verify all examples.
- `ruby examples/example_science_class_balance.rb`: Run a specific simulation experiment.

### Rules Management & Ignored Files
- **Research Policy**: Files and directories listed in `.gitignore` (such as `rules_reference/`) are **not off-limits** for reading. They often contain critical context (e.g., rule text, PDFs) that must be used during the research phase.
- **Commit Policy**: While these files should be read for information, they must **never** be staged or committed to the repository.
- **Tooling**: When searching for rules or context, use tools with `no_ignore: true` or `respect_git_ignore: false` to ensure ignored reference material is included in the search.

### Validation & Quality Standards
- **Math Transparency**: Ensure rolls and critical logic are logged with full metadata for debugging and validation. Resolution objects like `AttackResult` must carry enough metadata for deep analysis.
- **Empirical Proof**: For balance changes or mechanical implementations, provide a simulation script (in `examples/`) that runs at least 10,000 rounds to verify expected mathematical outcomes.
- **Fast Development Cycle**: Use `FAST_SIM=true bundle exec rake all` to skip slow simulations (> 5s) and run examples in parallel.
- **Modular Design**: Even in experimental scripts, extract logic into focused methods (< 10 lines) to satisfy complexity constraints.
