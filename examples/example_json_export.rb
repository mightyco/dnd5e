# frozen_string_literal: true

require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require 'logger'

puts '=== JSON Export Example ==='
puts 'Running 10 simulations and exporting to results.json...'

# Setup Scenario
hero = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_fighter(level: 1).build
goblin = Dnd5e::Builders::MonsterBuilder.new(name: 'Goblin').as_goblin.build

team_hero = Dnd5e::Core::Team.new(name: 'Heroes', members: [hero])
team_goblin = Dnd5e::Core::Team.new(name: 'Monsters', members: [goblin])

scenario = Dnd5e::Simulation::ScenarioBuilder.new(num_simulations: 10)
                                             .with_team(team_hero)
                                             .with_team(team_goblin)
                                             .build

# Use the new JSON handler
handler = Dnd5e::Simulation::JSONCombatResultHandler.new

runner = Dnd5e::Simulation::Runner.new(
  scenario: scenario,
  result_handler: handler,
  logger: Logger.new(nil)
)

runner.run
runner.export_json('results.json')

if File.exist?('results.json')
  puts "Successfully exported results.json (#{File.size('results.json')} bytes)"
  # Print first 20 lines of JSON
  puts 'JSON Preview:'
  puts `head -n 20 results.json`
else
  puts 'Failed to export results.json'
end
