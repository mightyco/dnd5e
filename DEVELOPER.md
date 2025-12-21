
## Development Guide

### Architecture: Observer Pattern

The combat system uses the **Observer Pattern** to decouple the core mechanics from side effects like logging and statistics.

*   **Publisher:** `Dnd5e::Core::Combat` includes the `Publisher` module. It emits events such as `:combat_start`, `:round_start`, `:turn_start`, `:attack`, and `:combat_end`.
*   **Observers:** Classes like `CombatLogger` and `CombatStatistics` implement an `update(event, data)` method.
*   **Usage:** Do not add `puts` or `logger` calls directly into `Combat` or `TeamCombat`. Instead, emit an event via `notify_observers` and handle the output in an observer.

### Testing

We follow **Test-Driven Development (TDD)**.

1.  **Framework:** Minitest.
2.  **Runner:** Always run tests using `rake test` (or `bundle exec rake test`) to ensure the correct environment and globs are used.
3.  **Mocks:** Use `Minitest::Mock` or simple Structs/Classes for mocking dependencies like DiceRollers or Observers.

### Rules Management for AI Agents

To support the AI coding assistant's "Rules Sage" persona, we maintain a text-based reference of the D&D 2024 rules.

#### Setup
1.  **Obtain PDFs:** Place your legally obtained D&D 2024 Core Rulebook PDFs into the `rules_reference/` directory.
    *   *Note:* This directory is `.gitignored` to prevent copyright infringement. Do not commit these files.
2.  **Extract Text:** Run the extraction script to convert PDFs to lightweight text files.
    ```bash
    ruby extract_rules.rb
    ```
    *   This requires the `pdf-reader` gem (`bundle install` or `gem install pdf-reader`).

#### How it Works
*   The `.cursorrules` file instructs the AI to read `rules_reference/*.txt` when answering rules questions.
*   This ensures the AI uses the actual text of the rules rather than potentially hallucinated or outdated training data.
