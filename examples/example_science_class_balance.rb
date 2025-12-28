# frozen_string_literal: true

require_relative '../lib/dnd5e/experiments/experiment'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/armor'

puts '=== Class Balance Experiments ==='

# --- Helper Methods ---

def create_fighter(name, level)
  Dnd5e::Builders::CharacterBuilder.new(name: name)
                                   .as_fighter(level: level, abilities: { strength: 16, constitution: 14 })
                                   .build
end

def create_wizard(name, level)
  char = Dnd5e::Builders::CharacterBuilder.new(name: name)
                                          .as_wizard(level: level, abilities: { intelligence: 16, dexterity: 14,
                                                                                constitution: 14 })
                                          .build

  add_fireball(char) if level >= 5
  char
end

def add_fireball(char)
  fireball = Dnd5e::Core::Attack.new(
    name: 'Fireball',
    damage_dice: Dnd5e::Core::Dice.new(8, 6),
    type: :save,
    save_ability: :dexterity,
    dc_stat: :intelligence,
    half_damage_on_save: true
  )
  char.attacks.unshift(fireball)
end

def create_team(name, composition, level)
  members = generate_members(composition, level)
  Dnd5e::Core::Team.new(name: name, members: members)
end

def generate_members(composition, level)
  members = []
  composition.each do |role, count|
    count.times do |i|
      member_name = "#{role.capitalize} #{i + 1}"
      members << (role == :fighter ? create_fighter(member_name, level) : create_wizard(member_name, level))
    end
  end
  members
end

# --- Experiment 1: 1v1 Scaling (Level 1-10) ---
puts "\n--- Experiment 1: 1v1 Fighter vs Wizard Scaling ---"
Dnd5e::Experiments::Experiment.new(name: '1v1 Scaling')
                              .independent_variable(:level, values: 1..10)
                              .simulations_per_step(200)
                              .control_group { |p| create_team('Fighter', { fighter: 1 }, p[:level]) }
                              .test_group { |p| create_team('Wizard', { wizard: 1 }, p[:level]) }
                              .run

# --- Experiment 2: Group Tactics (3v3 at Level 5) ---
puts "\n--- Experiment 2: 3v3 Composition at Level 5 ---"
# We want to vary composition: 3 Fighters vs (1W 2F), (2W 1F), (3W)
compositions = [
  { fighters: 3, wizards: 0 }, # Control
  { fighters: 2, wizards: 1 },
  { fighters: 1, wizards: 2 },
  { fighters: 0, wizards: 3 }
]

compositions.each do |comp|
  # Skip pure fighter vs pure fighter (control vs control)
  next if comp[:wizards].zero?

  test_name = "#{comp[:fighters]}F #{comp[:wizards]}W"
  puts "\nComparing 3 Fighters vs #{test_name}..."

  Dnd5e::Experiments::Experiment.new(name: "3v3: 3F vs #{test_name}")
                                .independent_variable(:dummy, values: [5]) # Fixed level 5
                                .simulations_per_step(200)
                                .control_group { |_| create_team('Pure Fighters', { fighter: 3 }, 5) }
                                .test_group do |_|
                                  create_team('Mixed Party',
                                              { fighter: comp[:fighters], wizard: comp[:wizards] }, 5)
  end
                                .run
end

# --- Experiment 3: Swarm Scaling (1 Fighter vs N Wizards at Level 1) ---
puts "\n--- Experiment 3: The Action Economy (1 Lvl 5 Fighter vs N Lvl 1 Wizards) ---"
Dnd5e::Experiments::Experiment.new(name: 'Action Economy')
                              .independent_variable(:wizard_count, values: 1..5)
                              .simulations_per_step(200)
                              .control_group { |_| create_team('Boss Fighter', { fighter: 1 }, 5) }
                              .test_group { |p| create_team('Wizard Swarm', { wizard: p[:wizard_count] }, 1) }
                              .run
