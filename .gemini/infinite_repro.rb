require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require 'timeout'

sc = { method: :as_monk, subclass: :openhand }
enc = { name: 'Swarm (6 Goblins)', monsters: 6, type: :goblin }

begin
  Timeout.timeout(30) do
    puts "Running 100 simulations of Monk vs 6 Goblins..."
    builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').send(sc[:method], level: 5, subclass: sc[:subclass])
    hero = builder.build
    monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Enemy')
    monsters = enc[:monsters].times.map { monster_builder.send("as_#{enc[:type]}").build }
    teams = [Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]), Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)]
    scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: 100)
    handler = Dnd5e::Simulation::JSONCombatResultHandler.new
    runner = Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler)
    runner.run
    puts "DONE"
  end
rescue Timeout::Error
  puts "HANG DETECTED IN BATCH"
  exit 1
end
