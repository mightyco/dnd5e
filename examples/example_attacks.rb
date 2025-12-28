# frozen_string_literal: true

require_relative '../lib/dnd5e/core/combat'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/monster'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/combat_logger'
require_relative '../lib/dnd5e/core/attack_resolver'
require 'logger'

puts '=== Attack Mechanics Example ==='

# Setup
logger = Logger.new($stdout)
logger.formatter = proc { |_sev, _dt, _prog, msg| "#{msg}\n" }
combat_logger = Dnd5e::Core::CombatLogger.new(logger)

# Hero Setup
hero_stats = Dnd5e::Core::Statblock.new(name: 'Hero', strength: 16, level: 3)
hero = Dnd5e::Core::Character.new(name: 'Aragorn', statblock: hero_stats)
hero.attacks << Dnd5e::Core::Attack.new(name: 'Longsword', damage_dice: Dnd5e::Core::Dice.new(1, 8),
                                        relevant_stat: :strength)

# Goblin Setup
goblin_stats = Dnd5e::Core::Statblock.new(name: 'Goblin', strength: 8, dexterity: 14, hit_points: 7)
goblin = Dnd5e::Core::Monster.new(name: 'Goblin', statblock: goblin_stats)

# Resolve Attack
puts "\n--- Scenario: Resolving a single attack ---"
Dnd5e::Core::AttackResolver.new
# To use CombatLogger, we need to wire it up or mock the event.
# CombatLogger listens to Combat, not AttackResolver directly in current architecture.
# But for this example, let's use Combat to drive it properly.

combat = Dnd5e::Core::Combat.new(combatants: [hero, goblin])
combat.add_observer(combat_logger)

# Force an attack
combat.attack(hero, goblin)
