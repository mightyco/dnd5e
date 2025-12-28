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

### AI Style Guide (Strict Enforcement)
To avoid wasted cycles on linting errors, the AI Assistant must strictly adhere to the following rules **during generation**:

1.  **Frozen String Literals (MANDATORY)**
    *   **Every** Ruby file must start with: `# frozen_string_literal: true`
    *   This includes test files, helper files, and scripts.

2.  **Quote Style**
    *   Use single quotes `'string'` by default.
    *   Use double quotes `"string"` **only** when string interpolation (`"#{val}"`) is required.

3.  **Method Length & Complexity**
    *   **Max Lines:** 10 lines per method.
    *   **Strategy:** Extract logic into private helper methods *before* writing the main method.
    *   **Parameter Lists:** Use keyword arguments (`**options`) if a method takes more than 3 arguments.

4.  **Testing Best Practices (Minitest)**
    *   **Boolean Assertions:**
        *   Allowed: `assert_predicate object, :valid?`
        *   BANNED: `assert object.valid?`
    *   **Refutations:**
        *   Allowed: `refute_predicate object, :valid?`
        *   BANNED: `refute object.valid?`

5.  **Naming Conventions**
    *   Methods that return a boolean must end in `?` (e.g., `def valid?`, not `def valid`).

6.  **Formatting**
    *   **Line Length:** Hard limit of 120 characters. Break long lines (especially comments and method calls).
    *   **Trailing Whitespace:** Ensure no trailing whitespace exists.
    *   **Alignment:** Align hash keys and method arguments vertically if they span multiple lines.

7.  **Documentation**
    *   Public classes and methods must have RDoc comments explaining parameters and return values.

### Common Style Mistakes & Guidelines
(Legacy section kept for reference)

1.  **Class/Method Length:**
    *   Keep classes under 100 lines and methods under 10 lines where possible.
    *   Extract complex logic (like `setup` methods in tests) into helper methods.
    *   Use the Builder pattern to simplify object construction logic.

2.  **Complexity (ABC Size):**
    *   Avoid methods that do too much (Assignment, Branching, Conditionals).
    *   Split methods that parse, calculate, and report into separate, focused methods.
