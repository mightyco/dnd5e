# frozen_string_literal: true

require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/core/features/improved_critical'
require_relative '../lib/dnd5e/simulation/standard_encounter_suite'

# Standardized Encounter Suite (SES) Benchmark
# Compares different Fighter archetypes across three controlled scenarios.

def create_standard_builder(level)
  proc do
    Dnd5e::Builders::CharacterBuilder.new(name: 'Standard')
                                     .as_fighter(level: level, abilities: { strength: 16, constitution: 14 })
                                     .build
  end
end

def create_champion_builder(level)
  proc do
    Dnd5e::Builders::CharacterBuilder.new(name: 'Champion')
                                     .as_fighter(level: level, abilities: { strength: 16, constitution: 14 })
                                     .with_feature(Dnd5e::Core::Features::ImprovedCritical.new)
                                     .build
  end
end

def create_mastery_builder(level)
  proc do
    char = Dnd5e::Builders::CharacterBuilder.new(name: 'Mastery')
                                            .as_fighter(level: level, abilities: { strength: 16, constitution: 14 })
                                            .with_feature(Dnd5e::Core::Features::ImprovedCritical.new)
                                            .build
    # Add Vexing Shortsword
    vex_sword = Dnd5e::Core::Attack.new(name: 'Vexing Shortsword', damage_dice: Dnd5e::Core::Dice.new(1, 6),
                                        relevant_stat: :strength, mastery: :vex)
    char.attacks = [vex_sword]
    char
  end
end

def print_results(label, suite)
  puts "\n=== #{label} Results ==="
  %i[boss pack swarm].each do |type|
    res = suite.results[type]
    puts "#{res[:name]}:"
    puts "  Win Rate: #{res[:win_rate]}% | Avg Dealt: #{res[:avg_deal].round(1)} | " \
         "Avg Taken: #{res[:avg_take].round(1)} | Efficiency: #{res[:efficiency]}"
  end
  puts "Aggregate Efficiency Rating: #{suite.results[:aggregate_efficiency]}"
end

LEVEL = 5
NUM_SIMS = 1000 # Higher for more accuracy

puts "Running Standardized Encounter Suite (Level #{LEVEL}, #{NUM_SIMS} sims per scenario)..."

standard_suite = Dnd5e::Simulation::StandardEncounterSuite.new(create_standard_builder(LEVEL),
                                                               num_simulations: NUM_SIMS)
standard_suite.run_all
print_results('Standard Fighter', standard_suite)

champion_suite = Dnd5e::Simulation::StandardEncounterSuite.new(create_champion_builder(LEVEL),
                                                               num_simulations: NUM_SIMS)
champion_suite.run_all
print_results('Champion Fighter', champion_suite)

mastery_suite = Dnd5e::Simulation::StandardEncounterSuite.new(create_mastery_builder(LEVEL), num_simulations: NUM_SIMS)
mastery_suite.run_all
print_results('Mastery Champion', mastery_suite)
