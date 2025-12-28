# Examples Style Guide

The purpose of these examples is to demonstrate specific mechanics or scenarios in a way that is both **informative** (showing the math) and **flavorful** (telling a combat story).

## General Rules

1.  **Top-Level Script**: Examples should be executable scripts. You don't need to wrap them in `module Dnd5e::Examples`.
2.  **Self-Contained**: Minimize external dependencies. Require what you need at the top.
3.  **Builders**: Use `Dnd5e::Builders::CharacterBuilder` or similar helpers to keep setup code concise.
4.  **Logging**: Use `Dnd5e::Core::CombatLogger` for detailed, standardized combat output. Configure it to output to `STDOUT`.
    *   This ensures consistent formatting across examples (e.g., showing save DCs, damage rolls).
    *   Example: `logger = Logger.new($stdout); combat.add_observer(Dnd5e::Core::CombatLogger.new(logger))`

## Output Format

Outputs should generally follow the standard `CombatLogger` format, which includes:
*   Attack/Save details (Rolls, Modifiers, DCs).
*   Damage application.
*   Condition changes (Defeated).

Scientific/Statistical examples may use aggregated output (tables/charts) instead of per-turn logging.

## Code Template

```ruby
# frozen_string_literal: true

require_relative '../lib/dnd5e/core/combat'
require_relative '../lib/dnd5e/core/combat_logger'
require 'logger'
# ... other requires ...

# Setup using Builders
hero = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_fighter(level: 1).build
goblin = Dnd5e::Builders::MonsterBuilder.new(name: 'Goblin').build

# Combat Setup
combat = Dnd5e::Core::Combat.new(combatants: [hero, goblin])

# Configure Logger
logger = Logger.new($stdout)
logger.formatter = proc { |_sev, _dt, _prog, msg| "#{msg}\n" }
combat.add_observer(Dnd5e::Core::CombatLogger.new(logger))

# Execution
puts "=== Mechanics Demo ==="
combat.run_combat
```
