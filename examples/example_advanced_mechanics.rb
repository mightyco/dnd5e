# frozen_string_literal: true

require_relative '../lib/dnd5e/core/dice_roller'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/combat'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/combat_logger'
require_relative '../lib/dnd5e/core/features/great_weapon_master'

def run_scenario(name, attacker, defender, options = {})
  puts "\n--- #{name} ---"
  combat = Dnd5e::Core::Combat.new(combatants: [attacker, defender])
  # Use default logger to preserve format (severity, timestamp)
  logger = Logger.new($stdout)
  logger.level = Logger::DEBUG
  combat.add_observer(Dnd5e::Core::CombatLogger.new(logger))
  combat.attack(attacker, defender, **options)

  defender.statblock.hit_points = 50
end

puts '=== Advanced Mechanics Example ==='

# Setup
attacker_stats = Dnd5e::Core::Statblock.new(name: 'Hero', strength: 16) # +3 Mod
defender_stats = Dnd5e::Core::Statblock.new(name: 'Villain', armor_class: 15, hit_points: 50)
attacker = Dnd5e::Core::Character.new(
  name: 'Hero',
  statblock: attacker_stats,
  features: [Dnd5e::Core::Features::GreatWeaponMaster.new]
)
defender = Dnd5e::Core::Character.new(name: 'Villain', statblock: defender_stats)

# Give attacker a Greatsword (2d6)
damage_dice = Dnd5e::Core::Dice.new(2, 6, modifier: 3) # +3 Str
attacker.attacks << Dnd5e::Core::Attack.new(
  name: 'Greatsword',
  hit_bonus: 3,
  damage_dice: damage_dice
)

# 1. Normal Attack
run_scenario('Normal Attack', attacker, defender)

# 2. Advantage
run_scenario('Attack with Advantage', attacker, defender, advantage: true)

# 3. Disadvantage
run_scenario('Attack with Disadvantage', attacker, defender, disadvantage: true)

# 4. Great Weapon Master (-5 Hit, +10 Dmg)
run_scenario('Great Weapon Master Attack (-5/+10)', attacker, defender, great_weapon_master: true)

# 5. Critical Hit Simulation
puts "\n--- Forced Critical Hit ---"
mock_roller = Dnd5e::Core::MockDiceRoller.new([20, 10])
crit_attacker = Dnd5e::Core::Character.new(name: 'CritHero', statblock: attacker_stats.deep_copy)
crit_attacker.attacks << Dnd5e::Core::Attack.new(
  name: 'Greatsword',
  damage_dice: Dnd5e::Core::Dice.new(2, 6, modifier: 3),
  dice_roller: mock_roller
)

combat = Dnd5e::Core::Combat.new(combatants: [crit_attacker, defender], dice_roller: mock_roller)
logger = Logger.new($stdout)
logger.level = Logger::DEBUG
combat.add_observer(Dnd5e::Core::CombatLogger.new(logger))
combat.attack(crit_attacker, defender)
defender.statblock.hit_points = 50
