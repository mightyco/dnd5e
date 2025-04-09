# Developer Guidelines

This document outlines the design and technical principles that guide the development of the D&D 5e Combat Simulator. These guidelines are intended to promote code quality, maintainability, and collaboration.

## Core Principles

### 1. Single Purpose Principle

*   **Concept:** Each class, module, and method should have one, and only one, responsibility. This enhances code clarity, reduces complexity, and improves maintainability.
*   **Rationale:** Components with multiple responsibilities are harder to understand, test, and reuse. Changes in one area can unintentionally impact others.
*   **Implementation:**
    *   Strive for focused classes and methods. Refactor components that take on multiple responsibilities into smaller, more focused ones.
    *   Use clear and descriptive names that reflect the component's single responsibility.
    *   Favor composition over inheritance (see [Composability and Inheritance](#3-composability-and-inheritance)).
*   **Example:**
    *   Instead of a `Character` class handling both stat calculations and attack logic, separate these into `StatBlock` and `Attack` classes.

### 2. Class Size

*   **Concept:** Keep classes small and focused. Smaller classes are easier to understand, test, and maintain.
*   **Rationale:** Large classes often violate the Single Purpose Principle, leading to increased complexity and reduced maintainability.
*   **Implementation:**
    *   Aim for classes that are easily understood at a glance.
    *   Break down large classes into smaller, more manageable ones.
    *   Extract common functionality into utility classes or modules.
    *   Favor composition over inheritance (see Composability and Inheritance).
*   **Example:**
    *   If the `Combat` class becomes too large, extract turn-handling logic into a separate `TurnManager` class.

### 3. Composability and Inheritance

*   **Concept:** Favor composition over inheritance for code reuse and flexibility. Use inheritance judiciously, only for clear "is-a" relationships.
*   **Rationale:** Inheritance can lead to tight coupling and the "fragile base class" problem. Composition promotes loose coupling and flexibility.
*   **Implementation:**
    *   Prefer creating objects that contain other objects (composition) over inheriting from them.
    *   Use inheritance only for clear "is-a" relationships (e.g., a `Dragon` "is-a" `Monster`).
    *   Avoid deep inheritance hierarchies.
    *   Use interfaces or abstract classes to define common behavior when appropriate.
*   **Example:**
    *   Instead of a complex inheritance hierarchy for attack types, create `Attack` objects that can be composed with different damage types and effects.

### 4. Test-Driven Development (TDD)

*   **Concept:** Write tests before writing the code they test. This ensures testability and that tests accurately reflect the desired behavior.
*   **Rationale:** TDD leads to better-designed code, fewer bugs, and a safety net for refactoring.
*   **Implementation:**
    *   Write a failing test that describes the desired behavior.
    *   Write the minimum code to make the test pass.
    *   Refactor to improve design and readability.
    *   Repeat for each new feature or bug fix.
    *   Maintain a comprehensive test suite.
*   **Example:**
    *   Before implementing attack damage logic, write a test that asserts the expected damage for a given attack and defense.

### 5. Incremental Changes Over Major Refactors

*   **Concept:** Prefer small, incremental changes over large refactors.
*   **Rationale:** Large refactors are risky and can introduce bugs. Small changes are easier to test, review, and reduce the risk of breaking existing functionality.
*   **Implementation:**
    *   Break down large tasks into smaller steps.
    *   Refactor in small increments, testing after each change.
    *   Avoid making major changes to multiple parts of the codebase simultaneously.
    *   Use version control to track changes and roll back if needed.
*   **Example:**
    *   Instead of rewriting the entire combat system, refactor one part at a time, like the attack logic or turn order.

## Code Style

*   **Concept:** Follow the standard Ruby style guide to ensure consistency and readability.
*   **Rationale:** Consistent code style makes the codebase easier to understand and maintain.
*   **Implementation:**
    *   Refer to the Ruby Style Guide for detailed guidelines.
    *   Use a linter (like RuboCop) to automatically check for style violations.
    *   Be consistent in your style choices.

## Documentation

*   **Concept:** All classes, modules, and methods should be documented using the latest RDoc format.
*   **Rationale:** Clear and comprehensive documentation is essential for understanding how the code works and how to use it. RDoc provides a standardized way to generate documentation from code comments.
*   **Implementation:**
    *   Use RDoc comments (e.g., `#`, `=begin/=end`, `##`) to document classes, modules, methods, and parameters.
    *   Include a description of the purpose of each component.
    *   Document the parameters and return values of methods.
    *   Use the latest RDoc features and syntax.
    *   Generate documentation using the `rdoc` command.
    *   Ensure that documentation is kept up-to-date with code changes.
* **Example:**
```ruby
    # This class represents a character's stat block.
    class StatBlock
      # @param strength [Integer] The character's strength score.
      # @param dexterity [Integer] The character's dexterity score.
      def initialize(strength:, dexterity:)
        @strength = strength
        @dexterity = dexterity
      end
    end
