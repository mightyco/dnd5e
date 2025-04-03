# dnd5e
D&D 5e Simulator

## Purpose
Test out different D&D 5E character concepts in battle simulations. 

## Roadmap
1.  Build the engine
1.  Create a UI Mock
1.  Create a simulation
1.  Provide a record and replay capability with exemplars
1.  Provide the ability to rate concepts against many simulation runs
1.  Provide a UI to allow others to use the concepts

## Contents

```shell
dnd5e_simulator/
├── bin/                     # Executable scripts (e.g., to run the simulator)
├── lib/                     # Core Ruby code (classes, modules, etc.)
│   ├── dnd5e/               # Main namespace for the simulator
│   │   ├── character/       # Classes related to characters (e.g., Character, Fighter, Wizard)
│   │   ├── combat/          # Classes related to combat (e.g., Battle, Attack, Damage)
│   │   ├── core/            # Core game mechanics (e.g., Dice, AbilityScore, SavingThrow)
│   │   ├── rules/           # Classes related to rules (e.g., Rulebook, Feats, Spells)
│   │   └── ...              # Other modules as needed
│   └── dnd5e.rb             # Main entry point for the library
├── test/                    # Unit and integration tests
│   ├── dnd5e/               # Tests for the dnd5e namespace
│   │   ├── character/       # Tests for character classes
│   │   ├── combat/          # Tests for combat classes
│   │   ├── core/            # Tests for core classes
│   │   ├── rules/           # Tests for rules classes
│   │   └── ...              # Other test files
│   ├── test_helper.rb       # Helper file for test setup
│   └── ...                  # Other test files
├── data/                    # Data files (e.g., character sheets, monster stats, spell lists)
├── docs/                    # Project documentation (e.g., API docs, design docs)
├── examples/                # Example usage of the simulator
├── Gemfile                  # Ruby gem dependencies
├── Gemfile.lock             # Locked gem versions
├── Rakefile                 # Rake tasks (e.g., running tests, generating docs)
└── README.md                # Project description and instructions
```## Getting Started

### Prerequisites

*   Ruby 3.2 or higher
*   Bundler

### Installation

1.  Clone the repository:

    ```shell
    git clone https://github.com/yourusername/dnd5e.git
    cd dnd5e
    ```

2.  Install dependencies:

    ```shell
    bundle install
    ```

### Running Tests

```shell
bundle exec rake test
```

### Running the Simulator

```shell
bundle exec ruby bin/run_simulator.rb
```

### Contributing

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Make your changes and commit them.
4.  Push your branch to your fork.
5.  Submit a pull request.

### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
