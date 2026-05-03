require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require 'benchmark'

builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_barbarian(level: 5, subclass: :berserker)
hero = builder.build
monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Enemy')
monsters = 12.times.map { monster_builder.as_goblin.build }
teams = [Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]), Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)]
scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: 1)
handler = Dnd5e::Simulation::JSONCombatResultHandler.new
runner = Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler)

puts "Profiling 1 simulation with 12 Goblins..."
time = Benchmark.realtime do
  runner.run
end
puts "Time taken: #{time}s"
