# D&D 5e Combat Simulator

This project is a Ruby-based combat simulator for Dungeons & Dragons 5th Edition (D&D 5e). It allows you to simulate battles between teams of characters and monsters, providing insights into combat outcomes.

## Features

*   **Character and Monster Creation:** Define characters and monsters with stat blocks (strength, dexterity, etc.), hit points, and attacks.
*   **Team-Based Combat:** Create teams of characters and monsters to simulate battles.
*   **Combat Simulation:** Run multiple simulations of battles to analyze the probability of different outcomes.
*   **Reporting:** Generate reports summarizing the results of the simulations, including win rates and sample battle results.
* **Test Suite:** A robust test suite to ensure the code is working correctly.

## Getting Started

1.  **Prerequisites:**
    *   Ruby (version X.X.X or higher)
    *   Bundler (for managing dependencies)

2.  **Installation:**
    *   Clone the repository: `git clone <repository-url>`
    *   Navigate to the project directory: `cd dnd5e`
    *   Install dependencies: `bundle install`

3.  **Running the Tests:**
    *   `rake test`

4. **Running the Simulation**
    * See the `examples/` directory.

## Core Concepts

*   **Statblock:** Represents the core attributes of a character or monster (strength, dexterity, hit points, etc.).
*   **Character:** A player character with a stat block and attacks.
*   **Monster:** A non-player character with a stat block and attacks.
*   **Team:** A group of characters or monsters that fight together.
*   **Attack:** Represents an attack that a character or monster can perform.
*   **Combat:** Manages the flow of a single battle between teams.
*   **Runner:** Runs multiple combat simulations and aggregates the results.
* **Result:** Represents the result of a single combat.
* **Result Handler:** Handles the results of the combat.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

### Future Enhancements

*   More complex character classes and abilities.
*   More detailed combat logging.
*   Support for different types of attacks and damage.
*   A command-line interface (CLI) for running simulations.
*   Provide a record and replay capability with exemplars
*   Provide the ability to rate concepts against many simulation runs
*   Provide a UI to allow others to use the concepts

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
