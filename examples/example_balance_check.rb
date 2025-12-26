require_relative "../lib/dnd5e/core/team_combat"
require_relative "../lib/dnd5e/builders/team_builder"
require_relative "../lib/dnd5e/builders/character_builder"
require_relative "../lib/dnd5e/core/character"
require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/dice"
require_relative "../lib/dnd5e/simulation/runner"
require_relative "../lib/dnd5e/simulation/scenario_builder"
require_relative "../lib/dnd5e/simulation/simulation_combat_result_handler"
require_relative "../lib/dnd5e/core/statblock"
require 'logger'

# Setup identical statblocks
statblock = Dnd5e::Core::Statblock.new(
  name: "Soldier",
  strength: 14,
  dexterity: 14,
  constitution: 14,
  hit_die: "d8",
  level: 1
)

sword = Dnd5e::Core::Attack.new(
  name: "Sword",
  damage_dice: Dnd5e::Core::Dice.new(1, 8),
  relevant_stat: :strength
)

# Team A (5 Soldiers)
team_a_chars = (1..5).map do |i|
  Dnd5e::Builders::CharacterBuilder.new(name: "Red Soldier #{i}")
                           .with_statblock(statblock.deep_copy)
                           .with_attack(sword)
                           .build
end
team_a = Dnd5e::Core::Team.new(name: "Red Team", members: team_a_chars)

# Team B (5 Soldiers)
team_b_chars = (1..5).map do |i|
  Dnd5e::Builders::CharacterBuilder.new(name: "Blue Soldier #{i}")
                           .with_statblock(statblock.deep_copy)
                           .with_attack(sword)
                           .build
end
team_b = Dnd5e::Core::Team.new(name: "Blue Team", members: team_b_chars)

# Build Scenario
builder = Dnd5e::Simulation::ScenarioBuilder.new(num_simulations: 1000) # Lower count for readable log
builder.with_team(team_a)
builder.with_team(team_b)
scenario = builder.build

# Use Verbose Handler
logger = Logger.new($stdout)
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{msg}\n"
end
handler = Dnd5e::Simulation::SimulationCombatResultHandler.new(logger: logger)

puts "Running Balanced Simulation (1000 runs)..."
runner = Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler)
runner.run
runner.generate_report
