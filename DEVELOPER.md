# Developer Guide

This document covers rule management, code quality, and benchmarking for the D&D 2024 Combat Simulator.

## 📜 Rules Management for AI Agents

To support the AI coding assistant's "Rules Sage" persona, we maintain a text-based reference of the D&D 2024 rules.

### Setup
1.  **Obtain PDFs**: Place your legally obtained D&D 2024 Core Rulebook PDFs into the `rules_reference/` directory.
    *   *Note*: This directory is `.gitignored` to prevent copyright infringement. Do not commit these files.
2.  **Extract Text**: Run the extraction script to convert PDFs to lightweight text files.
    ```bash
    ruby extract_rules.rb
    ```
    *   This requires the `pdf-reader` gem (`bundle install` or `gem install pdf-reader`).

### How it Works
*   The `.cursorrules` file instructs the AI to read `rules_reference/*.txt` when answering rules questions.
*   This ensures the AI uses the actual text of the rules rather than potentially hallucinated or outdated training data.

## 🛠 Code Quality & Linting

We adhere to a strict Ruby Style Guide enforced by **RuboCop**.

### Strict Enforcement
All contributors and AI assistants **MUST** strictly adhere to the project's [STYLE_GUIDE.md](STYLE_GUIDE.md). This guide captures complexity, naming, and formatting rules that ensure a clean and maintainable engine.

Key mandates from the guide include:
- **Frozen String Literals**: Mandatory in every Ruby file.
- **Complexity**: Hard limit of 10 lines per method and 100 lines per class.
- **Boolean Naming**: Methods returning booleans must end in `?`.
- **Testing**: Use predicate assertions (`assert_predicate`) instead of standard boolean checks.

### Running the Linter
You MUST run RuboCop before committing any code.

```bash
rubocop
```

To automatically fix safe offenses:

```bash
rubocop -A
```

## 📊 Benchmarking

The project includes a utility script to time the execution of all examples. This is useful for detecting performance regressions in the core simulation loop.

### Performance Testing
Run the benchmarking script:

```bash
./time_examples.sh
```

This will output timing data to `execution_times.txt`. For fast validation during development, use the `FAST_SIM=true` environment variable to skip slow simulations (> 5s).

```bash
FAST_SIM=true bundle exec rake all
```
