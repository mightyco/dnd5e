require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'

MARTIAL_SUBCLASSES = [
  { method: :as_barbarian, subclass: :berserker, primary: :strength },
  { method: :as_fighter, subclass: :battlemaster, primary: :strength },
  { method: :as_fighter, subclass: :champion, primary: :strength },
  { method: :as_monk, subclass: :openhand, primary: :dexterity, secondary: :wisdom },
  { method: :as_paladin, subclass: :devotion, primary: :strength, secondary: :charisma },
  { method: :as_ranger, subclass: :hunter, primary: :dexterity, secondary: :wisdom },
  { method: :as_rogue, subclass: :assassin, primary: :dexterity }
]

TARGET_ENCOUNTERS = [
  { name: 'Duel (1 Bugbear)', monsters: 1, type: :bugbear },
  { name: 'Swarm (6 Goblins)', monsters: 6, type: :goblin }
]

def run_bench(sc, enc)
  abilities = { constitution: 14 }
  abilities[sc[:primary]] = 18
  abilities[sc[:secondary]] = 14 if sc[:secondary]
  
  builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').send(sc[:method], level: 5, subclass: sc[:subclass], abilities: abilities)
  hero = builder.build
  
  monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Enemy')
  monsters = enc[:monsters].times.map { monster_builder.send("as_#{enc[:type]}").build }
  
  teams = [Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]), Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)]
  scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: 100)
  handler = Dnd5e::Simulation::JSONCombatResultHandler.new
  Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler).run
  combats = JSON.parse(handler.to_json)
  combats.count { |c| c['winner'] == 'Heroes' }.to_f / combats.length * 100
end

MARTIAL_SUBCLASSES.each do |sc|
  TARGET_ENCOUNTERS.each do |enc|
    win_rate = run_bench(sc, enc)
    puts "#{sc[:method]} (#{sc[:subclass]}): #{enc[:name]} -> #{win_rate}%"
  end
end
