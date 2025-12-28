# frozen_string_literal: true

require_relative '../lib/dnd5e/core/dice_roller'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/combat'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/dice'

def run_scenario(name, attacker, defender, options = {})
  puts "\n--- #{name} ---"
  result = Dnd5e::Core::Combat.new(combatants: [attacker, defender]).attack(attacker, defender, **options)

  print_result_details(result, attacker, options)
  print_result_outcome(result, defender)

  defender.statblock.hit_points = 50
end

def print_result_details(result, attacker, options)
  mod = attacker.statblock.ability_modifier(:strength)
  mod -= 5 if options[:great_weapon_master]
  # Assuming attack_roll is final total. We reverse engineer for now as AttackResult doesn't store raw dice yet.
  raw = result.attack_roll - mod

  puts "Hero attacks and #{result.success ? 'hits' : 'misses'} (rolled a #{raw} + #{mod}: #{result.attack_roll}) " \
       "vs AC #{result.target_ac}"
end

def print_result_outcome(result, defender)
  if result.success
    puts "Result: HIT! Damage: #{result.damage}"
    puts "Defender HP remaining: #{defender.statblock.hit_points}"
  else
    puts 'Result: MISS!'
  end
end

puts '=== Advanced Mechanics Example ==='

# Setup
attacker_stats = Dnd5e::Core::Statblock.new(name: 'Hero', strength: 16) # +3 Mod
defender_stats = Dnd5e::Core::Statblock.new(name: 'Villain', armor_class: 15, hit_points: 50)
attacker = Dnd5e::Core::Character.new(name: 'Hero', statblock: attacker_stats)
defender = Dnd5e::Core::Character.new(name: 'Villain', statblock: defender_stats)

puts "Attacker: #{attacker.name} (Mod: +3)"
puts "Defender: #{defender.name} (AC: 15, HP: 50)"

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
puts "\n--- Great Weapon Master Attack (-5/+10) ---"
result = Dnd5e::Core::Combat.new(combatants: [attacker, defender]).attack(
  attacker, defender, great_weapon_master: true
)
print_result_details(result, attacker, { great_weapon_master: true })
print_result_outcome(result, defender)
defender.statblock.hit_points = 50

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
res = combat.attack(crit_attacker, defender)
print_result_details(res, crit_attacker, {})
print_result_outcome(res, defender)
puts '(Note: Damage doubled dice + mod)'
