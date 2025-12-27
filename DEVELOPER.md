
## Rules Management for AI Agents

To support the AI coding assistant's "Rules Sage" persona, we maintain a text-based reference of the D&D 2024 rules.

### Setup
1.  **Obtain PDFs:** Place your legally obtained D&D 2024 Core Rulebook PDFs into the `rules_reference/` directory.
    *   *Note:* This directory is `.gitignored` to prevent copyright infringement. Do not commit these files.
2.  **Extract Text:** Run the extraction script to convert PDFs to lightweight text files.
    ```bash
    ruby extract_rules.rb
    ```
    *   This requires the `pdf-reader` gem (`bundle install` or `gem install pdf-reader`).

### How it Works
*   The `.cursorrules` file instructs the AI to read `rules_reference/*.txt` when answering rules questions.
*   This ensures the AI uses the actual text of the rules rather than potentially hallucinated or outdated training data.

## Code Quality & Linting

We adhere to the Ruby Style Guide as enforced by **RuboCop**.

### Running the Linter
You MUST run RuboCop before committing any code.

```bash
rubocop
```

To automatically fix safe offenses:

```bash
rubocop -A
```

### Common Style Mistakes & Guidelines
During development, the following issues were frequently encountered and corrected. Please keep these in mind:

1.  **Class/Method Length:**
    *   Keep classes under 100 lines and methods under 10 lines where possible.
    *   Extract complex logic (like `setup` methods in tests) into helper methods.
    *   Use the Builder pattern to simplify object construction logic.

2.  **Complexity (ABC Size):**
    *   Avoid methods that do too much (Assignment, Branching, Conditionals).
    *   Split methods that parse, calculate, and report into separate, focused methods.

3.  **String Literals:**
    *   Use single quotes `'string'` by default.
    *   Use double quotes `"string"` only when using string interpolation or special characters.

4.  **Frozen String Literals:**
    *   Add `# frozen_string_literal: true` at the top of every Ruby file.
    *   This improves performance and memory usage.

5.  **Documentation:**
    *   Ensure all public classes and methods have RDoc comments.
    *   This is critical for the AI and future developers to understand the API.
