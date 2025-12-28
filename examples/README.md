# Examples Style Guide

The purpose of these examples is to demonstrate specific mechanics or scenarios in a way that is both **informative** (showing the math) and **flavorful** (telling a combat story).

## General Rules

1.  **Top-Level Script**: Examples should be executable scripts. You don't need to wrap them in `module Dnd5e::Examples`.
2.  **Self-Contained**: Minimize external dependencies. Require what you need at the top.
3.  **Builders**: Use `Dnd5e::Builders::CharacterBuilder` or similar helpers to keep setup code concise.
4.  **Custom Output**: Do **not** use the raw `Logger`. Use `puts` to create readable, narrated output.

## Output Format

Outputs should follow this general structure:

```text
=== Example Name ===
Description of the scenario.

--- Scenario 1: Basic Attack ---
Attacker: Hero (Str +3)
Defender: Goblin (AC 15, HP 7)

[Flavor Text] Hero swings their Longsword at Goblin!
[Mechanics] Attack Roll: 18 (15 + 3) vs AC 15
[Outcome]   HIT! 6 damage applied.
[Status]    Goblin has 1 HP remaining.
```

## Code Template

```ruby
# frozen_string_literal: true

require_relative '../lib/dnd5e/core/combat'
# ... other requires ...

def run_scenario(attacker, defender)
  puts "\n--- Scenario Name ---"
  # ... execution ...
end

# Setup using Builders
hero = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_fighter(level: 1).build
goblin = Dnd5e::Builders::MonsterBuilder.new(name: 'Goblin').build

# Execution
puts "=== Mechanics Demo ==="
run_scenario(hero, goblin)
```

