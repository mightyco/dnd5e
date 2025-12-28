# frozen_string_literal: true

require_relative '../lib/dnd5e/core/dice_roller'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/combat'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/dice'

# Helper to run a quick scenario
def run_scenario(name, attacker, defender, options = {})
  puts "\n--- #{name} ---"
  print_combatants(attacker, defender)

  hit = Dnd5e::Core::Combat.new(combatants: [attacker, defender]).attack(attacker, defender, **options)

  if hit
    puts 'Result: HIT!'
    puts "Defender HP remaining: #{defender.statblock.hit_points}"
  else
    puts 'Result: MISS!'
  end

  defender.statblock.hit_points = 50
end

def print_combatants(attacker, defender)
  puts "Attacker: #{attacker.name} (Mod: #{attacker.statblock.ability_modifier(:strength)})"
  puts "Defender: #{defender.name} (AC: #{defender.statblock.armor_class}, HP: #{defender.statblock.hit_points})"
end

puts '=== Advanced Mechanics Example ==='

# Setup
attacker_stats = Dnd5e::Core::Statblock.new(name: 'Hero', strength: 16) # +3 Mod
defender_stats = Dnd5e::Core::Statblock.new(name: 'Villain', armor_class: 15, hit_points: 50)
attacker = Dnd5e::Core::Character.new(name: 'Hero', statblock: attacker_stats)
defender = Dnd5e::Core::Character.new(name: 'Villain', statblock: defender_stats)

# Give attacker a Greatsword (2d6)
damage_dice = Dnd5e::Core::Dice.new(2, 6, modifier: 3) # +3 Str
attacker.attacks << Dnd5e::Core::Attack.new(
  name: 'Greatsword',
  hit_bonus: 3, # Proficiency(2) + Str(3) = +5 (Wait, auto-calc not fully there yet, manual for now)
  damage_dice: damage_dice
)

# 1. Normal Attack
run_scenario('Normal Attack', attacker, defender)

# 2. Advantage
run_scenario('Attack with Advantage', attacker, defender, advantage: true)

# 3. Disadvantage
run_scenario('Attack with Disadvantage', attacker, defender, disadvantage: true)

# 4. Great Weapon Master (-5 Hit, +10 Dmg)
# Note: With +3 mod vs AC 15, normal need 12+. With GWM, need 17+.
puts "\n--- Great Weapon Master Attack (-5/+10) ---"
puts 'Attempting a power attack...'
hit = Dnd5e::Core::Combat.new(combatants: [attacker, defender]).attack(
  attacker, defender, great_weapon_master: true
)
puts hit ? 'Result: SMASH! (+10 damage applied)' : 'Result: Missed (due to -5 penalty?)'
puts "Defender HP remaining: #{defender.statblock.hit_points}"

# 5. Critical Hit Simulation (Force a crit via mock)
puts "\n--- Forced Critical Hit ---"
mock_roller = Dnd5e::Core::MockDiceRoller.new([20, 10]) # 20 (Crit), 10 (Damage)
crit_attacker = Dnd5e::Core::Character.new(name: 'CritHero', statblock: attacker_stats.deep_copy)
crit_attacker.attacks << Dnd5e::Core::Attack.new(
  name: 'Greatsword',
  damage_dice: Dnd5e::Core::Dice.new(2, 6, modifier: 3),
  dice_roller: mock_roller
)

combat = Dnd5e::Core::Combat.new(combatants: [crit_attacker, defender], dice_roller: mock_roller)
combat.attack(crit_attacker, defender)
puts 'Rolled a Natural 20!'
puts "Defender HP remaining: #{defender.statblock.hit_points}"
puts '(Note: Damage should be higher than normal max due to doubled dice)'
