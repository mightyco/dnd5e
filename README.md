# D&D 5e Combat Simulator

This project is a Ruby-based combat simulator for Dungeons & Dragons 5th Edition (D&D 5e). It allows you to simulate battles between teams of characters and monsters, providing insights into combat outcomes.

## Features

*   **Character and Monster Creation:** Define characters and monsters with stat blocks (strength, dexterity, etc.), hit points, and attacks.
*   **Team-Based Combat:** Create teams of characters and monsters to simulate battles.
*   **Combat Simulation:** Run multiple simulations of battles to analyze the probability of different outcomes.
*   **Reporting:** Generate reports summarizing the results of the simulations, including win rates and sample battle results.
*   **Observer Pattern:** Extensible architecture allows you to plug in custom loggers, statistics collectors, or UI updaters without modifying core logic.
*   **Test Suite:** A robust test suite to ensure the code is working correctly.

## Getting Started

1.  **Prerequisites:**
    *   Ruby (3.3.9 or higher recommended)
    *   Bundler (for managing dependencies)

2.  **Installation:**
    *   Clone the repository: `git clone <repository-url>`
    *   Navigate to the project directory: `cd dnd5e`
    *   Install dependencies: `bundle install`

3.  **Running the Tests:**
    *   Run the full test suite via Rake:
        ```bash
        bundle exec rake test
        ```

4. **Running Examples:**
    *   Check the `examples/` directory for scripts demonstrating various features.
    *   Run an example:
        ```bash
        ruby examples/example_simulation.rb
        ```

## Core Concepts

*   **Statblock:** Represents the core attributes of a character or monster (strength, dexterity, hit points, etc.).
*   **Character/Monster:** Entities participating in combat, wrapping a statblock and a list of attacks.
*   **Team:** A group of combatants that fight together.
*   **Combat:** Manages the flow of a single battle (initiative, turns, rounds). It acts as a **Publisher**, notifying observers of events.
*   **Runner:** Runs multiple combat simulations and aggregates the results.
*   **Observers:** Components that listen to combat events. Built-in observers include:
    *   `CombatLogger`: Prints battle narrative to the console or log files.
    *   `CombatStatistics`: Collects data on wins and initiative for reporting.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues. See [DEVELOPER.md](DEVELOPER.md) for coding standards and guidelines.

### Future Enhancements

*   More complex character classes and abilities.
*   Support for different types of attacks and damage (magic, saving throws).
*   A command-line interface (CLI) for running simulations.
*   Provide a record and replay capability with exemplars.
*   Provide the ability to rate concepts against many simulation runs.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
