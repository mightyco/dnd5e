# Ruby Style Guide & Project Conventions

This guide is derived from actual RuboCop failures encountered during the implementation of the D&D 2024 ruleset. Adhering to these rules prevents CI failures and ensures a clean, maintainable codebase.

## 1. Core Syntax & Formatting
*   **Frozen String Literals**: Every file MUST start with `# frozen_string_literal: true`.
*   **Quotes**: Prefer single quotes `'string'` for all literals. Use double quotes `"string"` ONLY for interpolation or special symbols.
*   **Whitespace**: No trailing whitespace. Exactly one empty line at the end of the file.
*   **Magic Comments**: Leave exactly one empty line after the `# frozen_string_literal` comment.
*   **Line Length**: Keep lines under **120 characters**.

## 2. Naming & Methods
*   **Predicates**:
    *   Methods returning booleans MUST end in `?`.
    *   Avoid redundant prefixes. Use `condition?(name)` instead of `has_condition?(name)`.
*   **Variable Numbers**: Avoid numbers in method or variable names (e.g., use `test_critical_at_nineteen` instead of `test_critical_on_19`).
*   **Duplicate Methods**: Never define a method that is already handled by `attr_accessor` or `attr_reader`.

## 3. Complexity & Size (Strict)
*   **Method Length**: Maximum **10 lines** per method. Extract helpers liberally.
*   **Class Length**: Maximum **100 lines** per class. Use Mixins/Modules for initialization or specialized logic.
*   **ABC Size**: Maximum **17.0**. Keep assignments, branches, and conditionals minimal.
*   **Block Chains**: Avoid multi-line chains of blocks (e.g., `.map { ... }.select { ... }` across 10 lines). Assign to a variable first.

## 4. Specific Object Usage
*   **OpenStruct**: NEVER use `OpenStruct`. It is slow and prone to bugs. Use `Struct.new`, `Hash`, or a dedicated data class.

## 5. Testing (Minitest)
*   **Predicate Assertions**:
    *   Use `assert_predicate obj, :method?` instead of `assert obj.method?`.
    *   Use `refute_predicate obj, :method?` instead of `refute obj.method?`.
*   **Spacing**: Ensure an empty line exists before assertion methods for readability.
*   **Refute**: Use `refute` or `refute_equal` for negative checks.

## 6. Layout & Alignment
*   **Def/End**: Ensure `end` is perfectly aligned with its `def`.
