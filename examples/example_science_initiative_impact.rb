# frozen_string_literal: true

require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/armor'
require_relative '../lib/dnd5e/experiments/experiment'

# Experiment: Initiative Impact with Team Size Scaling
# Objective: Isolate the advantage of going first by equalizing all other stats,
#            across different levels and team sizes.
# Method:
#   - Both combatants use Strength for attacks (Longsword).
#   - Both wear Heavy Armor (Chain Mail, AC 16). Heavy armor ignores Dex modifiers for AC.
#   - Both have equal Constitution (HP) and Strength (Attack/Damage).
#   - Variable: Dexterity (Initiative).
#     - Team A (Control): Dex 10 (+0 Init)
#     - Team B (Test):    Dex 20 (+5 Init)
#   - Variable: Team Size (1, 5, 10 combatants)

# We iterate through team sizes manually since Experiment class handles one main independent variable easily.
[1, 5, 10].each do |team_size|
  puts "\n=== Experiment: Team Size #{team_size} ==="
  
  experiment = Dnd5e::Experiments::Experiment.new(name: "Initiative Impact (Team Size #{team_size})")
                                             .simulations_per_step(500)
                                             .independent_variable(:level, values: [1, 5, 10])

  experiment.control_group do |params|
    # Control: Dex 10 (+0 Init)
    members = (1..team_size).map do |i|
      Dnd5e::Builders::CharacterBuilder.new(name: "Slow #{i}")
                                       .as_fighter(level: params[:level],
                                                   abilities: { strength: 16, dexterity: 10, constitution: 14 })
                                       .build
    end
    Dnd5e::Core::Team.new(name: 'Slow Team', members: members)
  end

  experiment.test_group do |params|
    # Test: Dex 20 (+5 Init)
    members = (1..team_size).map do |i|
      Dnd5e::Builders::CharacterBuilder.new(name: "Fast #{i}")
                                       .as_fighter(level: params[:level],
                                                   abilities: { strength: 16, dexterity: 20, constitution: 14 })
                                       .build
    end
    Dnd5e::Core::Team.new(name: 'Fast Team', members: members)
  end

  experiment.run
end
